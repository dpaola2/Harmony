#include "slab_backlight.h"
#include "slab_pins.h"
#include "driver/ledc.h"

#define MODE LEDC_LOW_SPEED_MODE
#define TIMER LEDC_TIMER_0
#define CHANNEL LEDC_CHANNEL_0
#define BITS LEDC_TIMER_10_BIT   /* 40 kHz x 1024 still fits the 80 MHz clock */

static uint32_t freq;
static unsigned duty_now;
static bool ready;

static esp_err_t timer(uint32_t hz)
{
    ledc_timer_config_t t = {.speed_mode = MODE, .duty_resolution = BITS, .timer_num = TIMER,
        .freq_hz = hz, .clk_cfg = LEDC_USE_APB_CLK};
    return ledc_timer_config(&t);
}

esp_err_t slab_backlight_init(uint32_t pwm_hz)
{
    esp_err_t err = timer(pwm_hz);
    ledc_channel_config_t c = {.gpio_num = SLAB_PIN_LCD_BL, .speed_mode = MODE, .channel = CHANNEL,
        .timer_sel = TIMER, .duty = 0, .hpoint = 0};
    if (err == ESP_OK) err = ledc_channel_config(&c);
    if (err == ESP_OK) err = ledc_stop(MODE, CHANNEL, 0);
    if (err == ESP_OK) { freq = pwm_hz; duty_now = 0; ready = true; }
    return err;
}

esp_err_t slab_backlight_set_freq(uint32_t pwm_hz)
{
    if (!ready) return slab_backlight_init(pwm_hz);
    esp_err_t err = timer(pwm_hz);
    if (err == ESP_OK) { freq = pwm_hz; err = slab_backlight_set_permille(duty_now); }
    return err;
}

uint32_t slab_backlight_freq(void) { return freq; }
unsigned slab_backlight_permille(void) { return duty_now; }

esp_err_t slab_backlight_set_permille(unsigned duty)
{
    if (!ready) return ESP_ERR_INVALID_STATE;
    if (duty > 1000) duty = 1000;
    duty_now = duty;
    /* Full on and full off hold the pin: no PWM edges on LCD_LEDA at all. */
    if (duty == 0) return ledc_stop(MODE, CHANNEL, 0);
    if (duty == 1000) return ledc_stop(MODE, CHANNEL, 1);
    uint32_t raw = (uint32_t)((duty * 1024u + 500u) / 1000u);
    esp_err_t err = ledc_set_duty(MODE, CHANNEL, raw);
    if (err == ESP_OK) err = ledc_update_duty(MODE, CHANNEL);
    return err;
}
