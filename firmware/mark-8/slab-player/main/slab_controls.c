/* Slab controls: touch wheel and side button to player UI events. */
#include <stdatomic.h>
#include "sdkconfig.h"
#include "slab_controls.h"
#include "controls_map.h"
#include "player_ui.h"
#include "slab_pins.h"
#include "slab_wheel.h"
#include "slab_buzzer.h"
#include "drv2605.h"
#include "driver/gpio.h"
#include "esp_log.h"
#include "esp_sleep.h"
#include "esp_timer.h"
#include "freertos/FreeRTOS.h"
#include "freertos/task.h"

#ifndef CONFIG_SLAB_SIDE_LONG_PRESS_MS
#define CONFIG_SLAB_SIDE_LONG_PRESS_MS 1500
#endif
#define WHEEL_TASK_PRIORITY 6   /* above the display (1) and the audio and Bluetooth workers (5); short bursts */
#define BUTTON_TASK_PRIORITY 3

static const char *TAG = "CONTROLS";
static atomic_bool sleep_requested, button_stop;
static atomic_uint last_activity;
static TaskHandle_t button_task;

static uint32_t now_ms(void) { return (uint32_t)(esp_timer_get_time() / 1000); }
bool slab_controls_take_sleep_request(void) { return atomic_exchange(&sleep_requested, false); }
uint32_t slab_controls_last_activity_ms(void) { return atomic_load(&last_activity); }

static void send(const controls_action_t *a, unsigned n)
{
    for (unsigned i = 0; i < n; ++i)
        if (!player_ui_input(a[i].input, a[i].delta)) ESP_LOGW(TAG, "UI input queue full");
}

/* Runs in the wheel task right after an MPR121 read: the quiet gap, so the
 * buzzer click and any haptic I2C write finish before the next measurement. */
static void on_wheel(const wheel_events_t *ev, const mpr121_frame_t *frame, void *ctx)
{
    (void)frame; (void)ctx;
    controls_action_t actions[CONTROLS_MAX_ACTIONS];
    unsigned n = controls_map_wheel(ev, actions, CONTROLS_MAX_ACTIONS);
    if (ev->touch_down || n) atomic_store(&last_activity, now_ms());
    if (!n) return;
    send(actions, n);
    unsigned steps = (unsigned)(ev->steps < 0 ? -ev->steps : ev->steps);
    if (ev->tap != WHEEL_ZONE_NONE || ev->hold != WHEEL_ZONE_NONE) {
        slab_buzzer_click(CONFIG_SLAB_CLICK_TAP_US);
#if CONFIG_SLAB_MOTOR_FITTED
        drv2605_play(DRV2605_EFFECT_SHARP_TICK);
#endif
    } else if (steps) {
        slab_buzzer_clicks(steps, CONFIG_SLAB_CLICK_SCROLL_US, CONFIG_SLAB_CLICK_SCROLL_US + 2500);
    }
    if (ev->tap != WHEEL_ZONE_NONE) ESP_LOGI(TAG, "tap %s", wheel_zone_name(ev->tap));
    if (ev->hold != WHEEL_ZONE_NONE) ESP_LOGI(TAG, "hold %s", wheel_zone_name(ev->hold));
}

static void side_button(void *unused)
{
    (void)unused;
    /* A press that woke the player is still down: ignore it until released. */
    while (!atomic_load(&button_stop) && gpio_get_level(SLAB_PIN_SIDE_BTN) == 0) vTaskDelay(pdMS_TO_TICKS(10));
    uint32_t down_at = 0;
    bool down = false, long_sent = false;
    unsigned stable = 0;
    while (!atomic_load(&button_stop)) {
        bool pressed = gpio_get_level(SLAB_PIN_SIDE_BTN) == 0;
        stable = pressed == down ? 0 : stable + 1;
        if (stable >= 3) {   /* 30 ms debounce */
            stable = 0;
            down = pressed;
            uint32_t now = now_ms();
            atomic_store(&last_activity, now);
            if (down) { down_at = now; long_sent = false; }
            else if (!long_sent) {
                controls_action_t a;
                if (controls_map_side_short(now - down_at, CONFIG_SLAB_SIDE_LONG_PRESS_MS, &a)) {
                    send(&a, 1);
                    slab_buzzer_click(CONFIG_SLAB_CLICK_TAP_US);
                }
            }
        }
        if (down && !long_sent && now_ms() - down_at >= CONFIG_SLAB_SIDE_LONG_PRESS_MS) {
            long_sent = true;
            slab_buzzer_clicks(2, CONFIG_SLAB_CLICK_TAP_US, 60000);
            atomic_store(&sleep_requested, true);
            ESP_LOGI(TAG, "long side press: deep sleep requested");
        }
        vTaskDelay(pdMS_TO_TICKS(10));
    }
    button_task = NULL;
    vTaskDelete(NULL);
}

esp_err_t slab_controls_start(const mpr121_settings_t *touch, const wheel_config_t *wheel)
{
    atomic_store(&last_activity, now_ms());
    if (esp_sleep_get_wakeup_cause() == ESP_SLEEP_WAKEUP_EXT1 && !mpr121_wait_untouched(3000))
        ESP_LOGW(TAG, "wheel still touched 3 s after the touch wake; starting anyway");
    esp_err_t err = mpr121_start(touch);
    if (err == ESP_OK) err = slab_wheel_start(wheel, on_wheel, NULL, WHEEL_TASK_PRIORITY, 0);
    if (err != ESP_OK) ESP_LOGE(TAG, "Touch wheel unavailable: %s", esp_err_to_name(err));
    atomic_store(&button_stop, false);
    if (xTaskCreatePinnedToCore(side_button, "side_button", 3072, NULL, BUTTON_TASK_PRIORITY, &button_task, 0) != pdPASS)
        return ESP_ERR_NO_MEM;
    return err;
}

void slab_controls_stop(void)
{
    slab_wheel_stop();
    atomic_store(&button_stop, true);
    for (int i = 0; i < 50 && button_task; ++i) vTaskDelay(pdMS_TO_TICKS(10));
}
