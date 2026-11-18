/* Wheel task: TOUCH_IRQ driven MPR121 reads, decoder, quiet-slot I2C work. */
#include <string.h>
#include "sdkconfig.h"
#include "slab_wheel.h"
#include "slab_pins.h"
#include "driver/gpio.h"
#include "esp_log.h"
#include "esp_timer.h"
#include "freertos/FreeRTOS.h"
#include "freertos/semphr.h"
#include "freertos/task.h"

#ifndef CONFIG_SLAB_WHEEL_TRACKING_PERIODS
#define CONFIG_SLAB_WHEEL_TRACKING_PERIODS 0
#endif
#define ESI_MS 16              /* 0x5D ESI 100 */
#define TICK_MS 20             /* hold detection while touched */
#define IDLE_CHECK_MS 250      /* stuck-IRQ check while untouched */
#define WORK_SLOTS 4

static const char *TAG = "WHEEL";
static SemaphoreHandle_t irq_sem, state_lock;
static TaskHandle_t task;
static volatile bool stop_requested;
static volatile uint32_t irq_count, read_count;
static wheel_state_t state;
static slab_wheel_cb_t callback;
static void *callback_ctx;
static portMUX_TYPE work_lock = portMUX_INITIALIZER_UNLOCKED;
static struct { slab_wheel_work_t fn; void *arg; uint32_t due_ms; } work[WORK_SLOTS];

static uint32_t now_ms(void) { return (uint32_t)(esp_timer_get_time() / 1000); }

static void IRAM_ATTR on_irq(void *arg)
{
    (void)arg;
    BaseType_t woken = pdFALSE;
    ++irq_count;
    xSemaphoreGiveFromISR(irq_sem, &woken);
    if (woken) portYIELD_FROM_ISR();
}

uint32_t slab_wheel_irq_count(void) { return irq_count; }
uint32_t slab_wheel_read_count(void) { return read_count; }
bool slab_wheel_running(void) { return task != NULL; }

bool slab_wheel_quiet_work(slab_wheel_work_t fn, void *arg, uint32_t max_wait_ms)
{
    bool queued = false;
    portENTER_CRITICAL(&work_lock);
    for (unsigned i = 0; i < WORK_SLOTS && !queued; ++i) {
        if (work[i].fn == fn && work[i].arg == arg) queued = true;   /* already waiting */
        else if (!work[i].fn) {
            work[i].fn = fn; work[i].arg = arg; work[i].due_ms = now_ms() + max_wait_ms; queued = true;
        }
    }
    portEXIT_CRITICAL(&work_lock);
    return queued;
}

/* Runs pending work. due_only: only work past its deadline. Returns how many ran. */
static unsigned run_work(bool due_only, bool dry_run)
{
    unsigned ran = 0;
    uint32_t now = now_ms();
    for (unsigned i = 0; i < WORK_SLOTS; ++i) {
        portENTER_CRITICAL(&work_lock);
        slab_wheel_work_t fn = work[i].fn;
        void *arg = work[i].arg;
        bool due = fn && (!due_only || (int32_t)(now - work[i].due_ms) >= 0);
        if (due && !dry_run) work[i].fn = NULL;
        portEXIT_CRITICAL(&work_lock);
        if (!due) continue;
        ++ran;
        if (!dry_run) fn(arg);
    }
    return ran;
}

static void deliver(const wheel_events_t *ev, const mpr121_frame_t *frame)
{
    if (callback) callback(ev, frame, callback_ctx);
}

static bool read_and_decode(void)
{
    mpr121_frame_t f;
    if (mpr121_read_frame(&f) != ESP_OK) return false;
    ++read_count;
    wheel_sample_t s = {.touched = f.touched, .t_ms = now_ms()};
    memcpy(s.delta, f.delta, sizeof(s.delta));
    xSemaphoreTake(state_lock, portMAX_DELAY);
    wheel_events_t ev = wheel_update(&state, &s);
    xSemaphoreGive(state_lock);
    deliver(&ev, &f);
    return true;
}

static void wheel_task(void *unused)
{
    (void)unused;
    uint32_t last_irq = 0;
    unsigned tracking_left = 0;
    unsigned failures = 0;
    bool resume_pending = false;
    while (!stop_requested) {
        bool active = state.active;
        uint32_t now = now_ms();
        TickType_t wait = pdMS_TO_TICKS(active ? TICK_MS : IDLE_CHECK_MS);
        uint32_t next_track = last_irq + (CONFIG_SLAB_WHEEL_TRACKING_PERIODS - tracking_left + 1) * ESI_MS + ESI_MS / 2;
        if (tracking_left) {
            int32_t until = (int32_t)(next_track - now);
            wait = until <= 0 ? 0 : pdMS_TO_TICKS(until);
        }
        bool irq = xSemaphoreTake(irq_sem, wait) == pdTRUE;
        if (stop_requested) break;
        now = now_ms();
        if (irq || gpio_get_level(SLAB_PIN_TOUCH_IRQ) == 0) {
            /* A touch measurement just finished: the bus is quiet for about 15 ms. */
            last_irq = now;
            bool ok = read_and_decode();
            failures = ok ? 0 : failures + 1;
            if (failures == 5) ESP_LOGE(TAG, "MPR121 reads failing");
            run_work(false, false);
            tracking_left = (CONFIG_SLAB_WHEEL_TRACKING_PERIODS && state.active) ? CONFIG_SLAB_WHEEL_TRACKING_PERIODS : 0;
            continue;
        }
        if (tracking_left && (int32_t)(now - next_track) >= 0) {
            --tracking_left;
            if (state.active) read_and_decode(); else tracking_left = 0;
            continue;
        }
        /* No read: the clock alone can still turn a still touch into a hold. */
        xSemaphoreTake(state_lock, portMAX_DELAY);
        wheel_events_t ev = wheel_tick(&state, now);
        bool idle = !state.active;
        xSemaphoreGive(state_lock);
        if (ev.hold != WHEEL_ZONE_NONE) deliver(&ev, NULL);
        /* Idle past a deadline: stop the MPR121 so the transfer cannot disturb a measurement. */
        if (idle && run_work(true, true)) {
            if (mpr121_stop() == ESP_OK) {
                run_work(true, false);
                resume_pending = true;
            }
        }
        /* A failed resume would leave the wheel dead with TOUCH_IRQ high: keep trying. */
        if (resume_pending) {
            resume_pending = mpr121_resume() != ESP_OK;
            if (resume_pending) ESP_LOGE(TAG, "MPR121 resume failed; retrying");
        }
    }
    task = NULL;
    vTaskDelete(NULL);
}

void slab_wheel_set_config(const wheel_config_t *cfg)
{
    if (state_lock) xSemaphoreTake(state_lock, portMAX_DELAY);
    wheel_init(&state, cfg);
    if (state_lock) xSemaphoreGive(state_lock);
}

wheel_state_t slab_wheel_state(void)
{
    wheel_state_t copy;
    xSemaphoreTake(state_lock, portMAX_DELAY);
    copy = state;
    xSemaphoreGive(state_lock);
    return copy;
}

esp_err_t slab_wheel_start(const wheel_config_t *cfg, slab_wheel_cb_t cb, void *ctx, unsigned priority, int core)
{
    if (task) return ESP_ERR_INVALID_STATE;
    if (!irq_sem) irq_sem = xSemaphoreCreateBinary();
    if (!state_lock) state_lock = xSemaphoreCreateMutex();
    if (!irq_sem || !state_lock) return ESP_ERR_NO_MEM;
    wheel_init(&state, cfg);
    callback = cb; callback_ctx = ctx;
    stop_requested = false;
    gpio_config_t io = {.pin_bit_mask = 1ULL << SLAB_PIN_TOUCH_IRQ, .mode = GPIO_MODE_INPUT,
        .pull_up_en = GPIO_PULLUP_DISABLE, .pull_down_en = GPIO_PULLDOWN_DISABLE,
        .intr_type = GPIO_INTR_NEGEDGE};   /* GPIO34 has no internal pulls; R11 10k pulls it up */
    esp_err_t err = gpio_config(&io);
    if (err == ESP_OK) {
        err = gpio_install_isr_service(0);
        if (err == ESP_ERR_INVALID_STATE) err = ESP_OK;   /* already installed */
    }
    if (err == ESP_OK) err = gpio_isr_handler_add(SLAB_PIN_TOUCH_IRQ, on_irq, NULL);
    if (err != ESP_OK) return err;
    if (xTaskCreatePinnedToCore(wheel_task, "slab_wheel", 6144, NULL, priority, &task, core) != pdPASS) {
        gpio_isr_handler_remove(SLAB_PIN_TOUCH_IRQ);
        task = NULL;
        return ESP_ERR_NO_MEM;
    }
    return ESP_OK;
}

esp_err_t slab_wheel_stop(void)
{
    if (!task) return ESP_OK;
    stop_requested = true;
    xSemaphoreGive(irq_sem);
    for (int i = 0; i < 100 && task; ++i) vTaskDelay(pdMS_TO_TICKS(5));
    gpio_isr_handler_remove(SLAB_PIN_TOUCH_IRQ);
    gpio_set_intr_type(SLAB_PIN_TOUCH_IRQ, GPIO_INTR_DISABLE);
    return task ? ESP_ERR_TIMEOUT : ESP_OK;
}
