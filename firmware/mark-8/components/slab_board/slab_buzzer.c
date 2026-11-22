#include "sdkconfig.h"
#include "slab_buzzer.h"
#include "slab_pins.h"
#include "driver/ledc.h"
#include "esp_timer.h"
#include "freertos/FreeRTOS.h"
#include "freertos/semphr.h"

#ifndef CONFIG_SLAB_CLICK_HZ
#define CONFIG_SLAB_CLICK_HZ 4000
#endif
#ifndef CONFIG_SLAB_CLICK_DUTY_PCT
#define CONFIG_SLAB_CLICK_DUTY_PCT 50
#endif
#define MODE LEDC_LOW_SPEED_MODE
#define TIMER LEDC_TIMER_1
#define CHANNEL LEDC_CHANNEL_1
#define BITS LEDC_TIMER_10_BIT

static esp_timer_handle_t stop_timer;
static SemaphoreHandle_t lock;   /* the wheel task and the side-button task both click */
static unsigned current_hz;
static volatile unsigned clicks_left, click_on_us, click_gap_us;
static volatile bool click_on;

static esp_err_t set(unsigned hz, unsigned duty_pct)
{
    if (!hz || !duty_pct) return ledc_stop(MODE, CHANNEL, 0);
    esp_err_t err = ESP_OK;
    if (hz != current_hz) {
        ledc_timer_config_t t = {.speed_mode = MODE, .duty_resolution = BITS, .timer_num = TIMER,
            .freq_hz = hz, .clk_cfg = LEDC_USE_APB_CLK};
        err = ledc_timer_config(&t);
        if (err == ESP_OK) current_hz = hz;
    }
    if (duty_pct > 50) duty_pct = 50;   /* a magnetic buzzer gains nothing above 50 percent */
    if (err == ESP_OK) err = ledc_set_duty(MODE, CHANNEL, duty_pct * 1024u / 100u);
    if (err == ESP_OK) err = ledc_update_duty(MODE, CHANNEL);
    return err;
}

/* Click sequencer: on for click_on_us, off for click_gap_us, clicks_left more times. */
static void stop(void *unused)
{
    (void)unused;
    if (click_on) {
        ledc_stop(MODE, CHANNEL, 0);
        click_on = false;
        if (clicks_left) esp_timer_start_once(stop_timer, click_gap_us);
    } else if (clicks_left) {
        --clicks_left;
        if (set(CONFIG_SLAB_CLICK_HZ, CONFIG_SLAB_CLICK_DUTY_PCT) == ESP_OK) {
            click_on = true;
            esp_timer_start_once(stop_timer, click_on_us);
        }
    }
}

esp_err_t slab_buzzer_init(void)
{
    ledc_timer_config_t t = {.speed_mode = MODE, .duty_resolution = BITS, .timer_num = TIMER,
        .freq_hz = CONFIG_SLAB_CLICK_HZ, .clk_cfg = LEDC_USE_APB_CLK};
    esp_err_t err = ledc_timer_config(&t);
    ledc_channel_config_t c = {.gpio_num = SLAB_PIN_BUZZER, .speed_mode = MODE, .channel = CHANNEL,
        .timer_sel = TIMER, .duty = 0, .hpoint = 0};
    if (err == ESP_OK) err = ledc_channel_config(&c);
    if (err == ESP_OK) err = ledc_stop(MODE, CHANNEL, 0);
    if (err == ESP_OK) current_hz = CONFIG_SLAB_CLICK_HZ;
    if (err == ESP_OK && !lock && !(lock = xSemaphoreCreateMutex())) err = ESP_ERR_NO_MEM;
    if (err == ESP_OK && !stop_timer) {
        esp_timer_create_args_t a = {.callback = stop, .name = "buzz_stop"};
        err = esp_timer_create(&a, &stop_timer);
    }
    return err;
}

void slab_buzzer_clicks(unsigned count, unsigned on_us, unsigned period_us)
{
    if (!stop_timer || !on_us || !count) return;
    if (count > 3) count = 3;
    xSemaphoreTake(lock, portMAX_DELAY);
    esp_timer_stop(stop_timer);
    click_on_us = on_us;
    click_gap_us = period_us > on_us ? period_us - on_us : 1000;
    clicks_left = count - 1;
    if (set(CONFIG_SLAB_CLICK_HZ, CONFIG_SLAB_CLICK_DUTY_PCT) == ESP_OK) {
        click_on = true;
        esp_timer_start_once(stop_timer, on_us);
    }
    xSemaphoreGive(lock);
}

void slab_buzzer_click(unsigned duration_us) { slab_buzzer_clicks(1, duration_us, 0); }

esp_err_t slab_buzzer_tone(unsigned hz, unsigned duty_pct)
{
    if (!lock) return ESP_ERR_INVALID_STATE;
    bool stop_only = !hz || !duty_pct;
    if (!stop_only && (hz < SLAB_TONE_MIN_HZ || hz > SLAB_TONE_MAX_HZ)) {
        slab_buzzer_tone(0, 0);
        return ESP_ERR_INVALID_ARG;
    }
    if (duty_pct > SLAB_TONE_MAX_DUTY_PCT) duty_pct = SLAB_TONE_MAX_DUTY_PCT;
    xSemaphoreTake(lock, portMAX_DELAY);
    if (stop_timer) esp_timer_stop(stop_timer);
    clicks_left = 0;
    click_on = false;
    esp_err_t err = set(stop_only ? 0 : hz, stop_only ? 0 : duty_pct);
    /* The click sequencer's stop path ends the tone after SLAB_TONE_MAX_MS. */
    if (err == ESP_OK && !stop_only && stop_timer) {
        click_on = true;
        esp_timer_start_once(stop_timer, (uint64_t)SLAB_TONE_MAX_MS * 1000u);
    }
    xSemaphoreGive(lock);
    return err;
}
