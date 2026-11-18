/* Mark-8 power: adapted from firmware/mark-7/pocket-player/main/player_power.c.
 * Battery percent comes from the MAX17048; the backlight duty follows VSYS;
 * deep sleep wakes on the side button (ext0) and on a wheel touch (ext1). */
#include <string.h>
#include "sdkconfig.h"
#include "player_power.h"
#include "player_ui.h"
#include "player_prefs.h"
#include "audio_player.h"
#include "player_bluetooth.h"
#include "slab_controls.h"
#include "slab_board.h"
#include "slab_analog.h"
#include "slab_backlight.h"
#include "slab_buzzer.h"
#include "slab_i2c.h"
#include "slab_wheel.h"
#include "max17048.h"
#include "drv2605.h"
#include "mpr121.h"
#include "st7365p.h"
#include "bench_storage.h"
#include "driver/gpio.h"
#include "driver/uart.h"
#include "esp_bt.h"
#include "esp_bt_main.h"
#include "esp_log.h"
#include "esp_sleep.h"
#include "esp_system.h"
#include "esp_timer.h"
#include "freertos/FreeRTOS.h"
#include "freertos/task.h"

#ifndef CONFIG_SLAB_SLEEP_TOUCH_ESI_MS
#define CONFIG_SLAB_SLEEP_TOUCH_ESI_MS 64
#endif
#ifndef CONFIG_SLAB_SLEEP_TOUCH_WAKE
#define CONFIG_SLAB_SLEEP_TOUCH_WAKE 0
#endif
#define GAUGE_PERIOD_MS 30000
#define GAUGE_MAX_WAIT_MS 300000   /* with the wheel idle this long, read with the MPR121 stopped */

static const char *TAG = "POWER";
static portMUX_TYPE lock = portMUX_INITIALIZER_UNLOCKED;
static player_power_status_t status;
static bool backlight_on;
static uint32_t last_gauge_request;

player_power_status_t player_power_status(void)
{
    portENTER_CRITICAL(&lock);
    player_power_status_t s = status;
    portEXIT_CRITICAL(&lock);
    return s;
}

/* Wheel task, in a quiet slot. */
static void read_gauge(void *unused)
{
    (void)unused;
    max17048_reading_t g;
    if (max17048_read(&g) != ESP_OK) return;
    portENTER_CRITICAL(&lock);
    status.valid = true;
    status.percent = g.percent;
    status.vcell_mv = g.vcell_mv;
    portEXIT_CRITICAL(&lock);
}

static void apply_backlight(void)
{
    player_power_status_t s = player_power_status();
    slab_bl_plan_t plan = slab_bl_plan(CONFIG_SLAB_BL_BRIGHTNESS_PCT, s.vsys_mv, s.usb);
    unsigned duty = backlight_on ? plan.duty_permille : 0;
    if (duty != slab_backlight_permille()) slab_backlight_set_permille(duty);
    portENTER_CRITICAL(&lock);
    status.bl_permille = duty;
    portEXIT_CRITICAL(&lock);
}

void player_power_init(uint32_t backlight_hz)
{
    ESP_LOGI(TAG, "Wake cause=%d; playback starts paused", (int)esp_sleep_get_wakeup_cause());
    slab_analog_init();
    slab_backlight_init(backlight_hz);
    max17048_hibernate(false);
    read_gauge(NULL);                  /* before the wheel task owns the bus */
    last_gauge_request = (uint32_t)(esp_timer_get_time() / 1000);
    player_power_poll();
    ESP_LOGI(TAG, "Battery %u %% (%u mV), USB %d, backlight PWM %u Hz", status.percent, status.vcell_mv,
             status.usb, (unsigned)backlight_hz);
}

void player_power_poll(void)
{
    int vbus = slab_analog_vbus_mv(), vbat = slab_analog_vbat_mv();
    if (vbus >= 0 && vbat >= 0) {
        portENTER_CRITICAL(&lock);
        status.usb = slab_vbus_present((unsigned)vbus);
        status.vsys_mv = slab_vsys_estimate_mv((unsigned)vbus, (unsigned)vbat);
        portEXIT_CRITICAL(&lock);
    }
    apply_backlight();
    uint32_t now = (uint32_t)(esp_timer_get_time() / 1000);
    if (now - last_gauge_request >= GAUGE_PERIOD_MS) {
        last_gauge_request = now;
        if (slab_wheel_running()) slab_wheel_quiet_work(read_gauge, NULL, GAUGE_MAX_WAIT_MS);
        else read_gauge(NULL);
    }
}

void player_power_backlight(bool on)
{
    backlight_on = on;
    apply_backlight();
}

static bool wait_shutdown(void)
{
    int64_t deadline = esp_timer_get_time() + 5000000;
    while (!player_bluetooth_shutdown() || !audio_player_shutdown_complete()) {
        if (esp_timer_get_time() > deadline) return false;
        vTaskDelay(pdMS_TO_TICKS(20));
    }
    return true;
}

void player_power_sleep(void)
{
    if (!player_prefs_flush()) { player_ui_notice("Save failed; staying awake"); return; }
    audio_player_set_paused(true);
    audio_player_stop();
    if (!wait_shutdown()) {
        ESP_LOGE(TAG, "Shutdown timed out; restarting paused instead of sleeping");
        esp_restart();
    }
    /* The managers are parked before the stack goes down, so no NVS write or
     * Bluetooth command can race the power transition. */
    if (esp_bluedroid_get_status() == ESP_BLUEDROID_STATUS_ENABLED) esp_bluedroid_disable();
    if (esp_bt_controller_get_status() == ESP_BT_CONTROLLER_STATUS_ENABLED) esp_bt_controller_disable();
    slab_controls_stop();
    slab_buzzer_tone(0, 0);
    player_power_backlight(false);
    st7365p_sleep();
    st7365p_deinit();
    bench_storage_unmount();
    /* The wheel task has stopped: this task owns the I2C bus now. */
    bool touch_wake = CONFIG_SLAB_SLEEP_TOUCH_WAKE;
    esp_err_t err = mpr121_sleep(touch_wake, CONFIG_SLAB_SLEEP_TOUCH_ESI_MS);
    if (err != ESP_OK) { ESP_LOGW(TAG, "MPR121 sleep setup: %s; side button wake only", esp_err_to_name(err)); touch_wake = false; }
    max17048_hibernate(true);
    drv2605_standby();
    slab_board_periph_power(false);
    slab_board_prepare_deep_sleep();
    /* The long press that asked for sleep is usually still down. */
    int64_t deadline = esp_timer_get_time() + 10000000;
    while (gpio_get_level(SLAB_PIN_SIDE_BTN) == 0 && esp_timer_get_time() < deadline) vTaskDelay(pdMS_TO_TICKS(10));
    vTaskDelay(pdMS_TO_TICKS(50));
    esp_sleep_enable_ext0_wakeup(SLAB_PIN_SIDE_BTN, 0);
    if (touch_wake) {
        /* TOUCH_IRQ must be high before sleep or the player wakes at once. */
        deadline = esp_timer_get_time() + 3000000;
        while (gpio_get_level(SLAB_PIN_TOUCH_IRQ) == 0 && esp_timer_get_time() < deadline) {
            uint8_t s[2];
            slab_i2c_read(SLAB_I2C_ADDR_MPR121, MPR121_REG_TOUCH_STATUS, s, 2);
            vTaskDelay(pdMS_TO_TICKS(50));
        }
        if (gpio_get_level(SLAB_PIN_TOUCH_IRQ)) esp_sleep_enable_ext1_wakeup(1ULL << SLAB_PIN_TOUCH_IRQ, ESP_EXT1_WAKEUP_ALL_LOW);
        else touch_wake = false;
    }
    ESP_LOGI(TAG, "DEEP_SLEEP: side button%s to wake; battery %u %%", touch_wake ? " or wheel touch" : "", status.percent);
    uart_wait_tx_idle_polling(CONFIG_ESP_CONSOLE_UART_NUM);
    esp_deep_sleep_start();
}
