/* Mark-8 copy of firmware/mark-7/pocket-player/main/main.c (October 9 working
 * tree), changed for the slab: board identity and the back-power-safe
 * 3V3_PERIPH start, the bring-up calibration (backlight PWM frequency and
 * touch thresholds), the touch wheel instead of the ANO, no bench test modes.
 * The Bluetooth start is unchanged; the device name is "Harmony Mark-8". */
#include <string.h>
#include "sdkconfig.h"
#include "esp_log.h"
#include "nvs_flash.h"
#include "esp_bt.h"
#include "esp_bt_main.h"
#include "esp_gap_bt_api.h"
#include "audio_player.h"
#include "player_display.h"
#include "player_bluetooth.h"
#include "player_power.h"
#include "slab_board.h"
#include "slab_i2c.h"
#include "slab_buzzer.h"
#include "slab_cal.h"
#include "slab_controls.h"
#include "drv2605.h"
#include "mpr121.h"
#include "wheel.h"
#define BT_AV_TAG "MARK8"

static void touch_settings(mpr121_settings_t *s, const slab_cal_t *cal, bool have_cal)
{
    mpr121_default_settings(s, CONFIG_SLAB_TOUCH_THRESHOLD, CONFIG_SLAB_RELEASE_THRESHOLD);
#if CONFIG_SLAB_TOUCH_SLOW_FALLING_BASELINE
    s->slow_falling_baseline = true;
#endif
#if CONFIG_SLAB_TOUCH_USE_SAVED
    if (have_cal) { memcpy(s->touch, cal->touch, 9); memcpy(s->release, cal->release, 9); }
#endif
}

static void wheel_settings(wheel_config_t *c, const mpr121_settings_t *touch)
{
    wheel_default_config(c);
    c->step_deg = CONFIG_SLAB_WHEEL_STEP_DEG; c->start_deg = CONFIG_SLAB_WHEEL_START_DEG;
    c->tap_max_ms = CONFIG_SLAB_WHEEL_TAP_MAX_MS; c->tap_max_deg = CONFIG_SLAB_WHEEL_TAP_MAX_DEG;
    c->hold_ms = CONFIG_SLAB_WHEEL_HOLD_MS; c->zone_half_deg = CONFIG_SLAB_WHEEL_ZONE_HALF_DEG;
    uint8_t weakest = 255;
    for (int i = 0; i < 9; ++i) if (touch->release[i] < weakest) weakest = touch->release[i];
    c->min_delta = weakest;   /* an angle needs at least a release-level signal */
#if CONFIG_SLAB_WHEEL_REVERSE
    c->reverse = true;
#endif
}

void app_main(void)
{
    if (slab_board_init() != ESP_OK) return;
    /* Preferences, Bluetooth bonds and the bring-up calibration share NVS; never erase it here. */
    esp_err_t ret = nvs_flash_init();
    if (ret != ESP_OK) ESP_LOGE(BT_AV_TAG, "NVS unavailable (%s); preferences cannot be saved", esp_err_to_name(ret));
    slab_cal_t cal;
    bool have_cal = ret == ESP_OK && slab_cal_load(&cal);
    uint32_t bl_hz = CONFIG_SLAB_BL_PWM_HZ ? CONFIG_SLAB_BL_PWM_HZ : have_cal ? cal.bl_pwm_hz : CONFIG_SLAB_BL_FALLBACK_HZ;
    ESP_LOGI(BT_AV_TAG, "Calibration %s; backlight PWM %u Hz", have_cal ? "from the bring-up" : "not saved (run slab-bringup)",
             (unsigned)bl_hz);
    if (slab_i2c_init() != ESP_OK) ESP_LOGE(BT_AV_TAG, "I2C unavailable");
#if CONFIG_SLAB_MOTOR_FITTED
    if (drv2605_detect(NULL)) drv2605_setup_erm();
#endif
    drv2605_standby();
    if (slab_board_periph_power(true) != ESP_OK) { ESP_LOGE(BT_AV_TAG, "3V3_PERIPH failed"); return; }
    slab_buzzer_init();
    player_power_init(bl_hz);
    if (!audio_player_prepare())
        ESP_LOGE(BT_AV_TAG, "Library unavailable; starting recovery UI");
    audio_player_set_paused(true);
    if (!player_display_start()) {
        audio_player_stop();
        ESP_LOGE(BT_AV_TAG, "Display preparation failed");
        return;
    }
    mpr121_settings_t touch;
    wheel_config_t wheel;
    touch_settings(&touch, &cal, have_cal);
    wheel_settings(&wheel, &touch);
    if (slab_controls_start(&touch, &wheel) != ESP_OK)
        ESP_LOGW(BT_AV_TAG, "Controls unavailable; continuing audio and display");
    /* Classic Bluetooth only: release the BLE controller memory. */
    ESP_ERROR_CHECK(esp_bt_controller_mem_release(ESP_BT_MODE_BLE));
    esp_bt_controller_config_t bt_cfg = BT_CONTROLLER_INIT_CONFIG_DEFAULT();
    if (esp_bt_controller_init(&bt_cfg) != ESP_OK) {
        ESP_LOGE(BT_AV_TAG, "%s initialize controller failed", __func__);
        return;
    }
    if (esp_bt_controller_enable(ESP_BT_MODE_CLASSIC_BT) != ESP_OK) {
        ESP_LOGE(BT_AV_TAG, "%s enable controller failed", __func__);
        return;
    }
    esp_bluedroid_config_t bluedroid_cfg = BT_BLUEDROID_INIT_CONFIG_DEFAULT();
#if (CONFIG_EXAMPLE_SSP_ENABLED == false)
    bluedroid_cfg.ssp_en = false;
#endif
    if ((ret = esp_bluedroid_init_with_cfg(&bluedroid_cfg)) != ESP_OK) {
        ESP_LOGE(BT_AV_TAG, "%s initialize bluedroid failed: %s", __func__, esp_err_to_name(ret));
        return;
    }
    if (esp_bluedroid_enable() != ESP_OK) {
        ESP_LOGE(BT_AV_TAG, "%s enable bluedroid failed", __func__);
        return;
    }
#if (CONFIG_EXAMPLE_SSP_ENABLED == true)
    /* Secure Simple Pairing: no input or output on this side. */
    esp_bt_sp_param_t param_type = ESP_BT_SP_IOCAP_MODE;
    esp_bt_io_cap_t iocap = ESP_BT_IO_CAP_NONE;
    esp_bt_gap_set_security_param(param_type, &iocap, sizeof(uint8_t));
#endif
    /* Legacy pairing: variable PIN. */
    esp_bt_pin_type_t pin_type = ESP_BT_PIN_TYPE_VARIABLE;
    esp_bt_pin_code_t pin_code;
    esp_bt_gap_set_pin(pin_type, 0, pin_code);
    if (!player_bluetooth_init())
        ESP_LOGE(BT_AV_TAG, "Bluetooth manager failed to start; UI remains available");
}
