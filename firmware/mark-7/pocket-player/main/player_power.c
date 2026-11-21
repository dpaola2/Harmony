#include "player_power.h"
#include "sdkconfig.h"
#include "player_ui.h"
#include "player_prefs.h"
#include "audio_player.h"
#include "player_bluetooth.h"
#include "carrier_controls.h"
#include "carrier_board.h"
#include "bench_display.h"
#include "esp_adc/adc_oneshot.h"
#include "esp_adc/adc_cali.h"
#include "esp_adc/adc_cali_scheme.h"
#include "driver/gpio.h"
#include "driver/rtc_io.h"
#include "esp_sleep.h"
#include "esp_system.h"
#include "esp_timer.h"
#include "esp_bt.h"
#include "esp_bt_main.h"
#include "esp_log.h"
#include "freertos/FreeRTOS.h"
#include "freertos/task.h"
static adc_oneshot_unit_handle_t adc;
static adc_cali_handle_t calibration;
static unsigned battery_mv;
static int64_t next_sample;
void player_power_init(void)
{
    ESP_LOGI("POWER", "Wake cause=%d; playback starts paused", esp_sleep_get_wakeup_cause());
    adc_oneshot_unit_init_cfg_t unit = {.unit_id=ADC_UNIT_1};
    adc_oneshot_chan_cfg_t channel = {.atten=ADC_ATTEN_DB_12, .bitwidth=ADC_BITWIDTH_DEFAULT};
    adc_cali_line_fitting_config_t cal = {.unit_id=ADC_UNIT_1, .atten=ADC_ATTEN_DB_12,
        .bitwidth=ADC_BITWIDTH_DEFAULT, .default_vref=1100};
    esp_err_t err = adc_oneshot_new_unit(&unit, &adc);
    if (err == ESP_OK) err = adc_oneshot_config_channel(adc, ADC_CHANNEL_7, &channel);
    if (err == ESP_OK) err = adc_cali_create_scheme_line_fitting(&cal, &calibration);
    if (err != ESP_OK) { calibration=NULL; ESP_LOGW("POWER", "Battery ADC unavailable: %s", esp_err_to_name(err)); }
}
unsigned player_power_battery_mv(void)
{
    int64_t now = esp_timer_get_time();
    if (!calibration || now < next_sample) return battery_mv;
    next_sample = now + 5000000;
    int sum=0;
    for (unsigned i=0;i<16;i++) {
        int raw, mv;
        if (adc_oneshot_read(adc, ADC_CHANNEL_7, &raw) != ESP_OK ||
            adc_cali_raw_to_voltage(calibration, raw, &mv) != ESP_OK) return battery_mv;
        sum += mv;
    }
    /* Feather V2 GPIO35 has a 200k/200k divider. Voltage, not state of charge. */
    battery_mv = ((unsigned)sum*2/16 + 5)/10*10;
    return battery_mv;
}
static bool wait_shutdown(void)
{
    int64_t deadline=esp_timer_get_time()+5000000;
    while (!player_bluetooth_shutdown() || !audio_player_shutdown_complete()) {
        if (esp_timer_get_time()>deadline) return false;
        vTaskDelay(pdMS_TO_TICKS(20));
    }
    return true;
}
void player_power_sleep(void)
{
#if CONFIG_MARK7_ANO_INPUT
#if CONFIG_MARK7_ANO_IRQ_WAKE
    if (!carrier_controls_wake_verified()) {
        player_ui_notice("Wake wire not checked; press a button");
        ESP_LOGW("POWER", "Sleep refused: verify INT->A2 and external 10k pull-up to 3V");
        return;
    }
#endif
    if (!player_prefs_flush()) { player_ui_notice("Save failed; staying awake"); return; }
    carrier_controls_arm_sleep();
    int64_t deadline=esp_timer_get_time()+5000000;
    while (carrier_controls_sleep_state()==1 && esp_timer_get_time()<deadline)
        vTaskDelay(pdMS_TO_TICKS(10));
    if (carrier_controls_sleep_state()!=2) {
        carrier_controls_cancel_sleep();
        player_ui_notice("Release buttons, then try Sleep again");
        return;
    }
    audio_player_set_paused(true);
    audio_player_stop();
    if (!wait_shutdown()) {
        ESP_LOGE("POWER", "Shutdown timed out; restarting paused instead of sleeping");
        esp_restart();
    }
    /* The manager is parked before disabling the stack, so no further NVS
     * writes or Bluetooth commands can race the power transition. */
    if (esp_bluedroid_get_status()==ESP_BLUEDROID_STATUS_ENABLED)
        ESP_ERROR_CHECK(esp_bluedroid_disable());
    if (esp_bt_controller_get_status()==ESP_BT_CONTROLLER_STATUS_ENABLED)
        ESP_ERROR_CHECK(esp_bt_controller_disable());
    ESP_ERROR_CHECK(bench_display_sleep());
    ESP_ERROR_CHECK(gpio_set_level(CARRIER_SD_CS,1));
    ESP_ERROR_CHECK(gpio_set_level(CARRIER_TFT_CS,1));
    ESP_ERROR_CHECK(gpio_hold_en(CARRIER_SD_CS));
    ESP_ERROR_CHECK(gpio_hold_en(CARRIER_TFT_CS));
    ESP_ERROR_CHECK(gpio_hold_en(CARRIER_TFT_LITE));
    gpio_deep_sleep_hold_en();
    /* Cable-only bench mode powers down QT and wakes with hardware Reset. */
    ESP_ERROR_CHECK(rtc_gpio_init(GPIO_NUM_2));
    ESP_ERROR_CHECK(rtc_gpio_set_direction(GPIO_NUM_2,RTC_GPIO_MODE_OUTPUT_ONLY));
#if CONFIG_MARK7_ANO_IRQ_WAKE
    ESP_ERROR_CHECK(rtc_gpio_set_level(GPIO_NUM_2,1));
#else
    ESP_ERROR_CHECK(rtc_gpio_set_level(GPIO_NUM_2,0));
#endif
    ESP_ERROR_CHECK(rtc_gpio_hold_en(GPIO_NUM_2));
#if CONFIG_MARK7_ANO_IRQ_WAKE
    ESP_ERROR_CHECK(esp_sleep_enable_ext0_wakeup(GPIO_NUM_34,0));
    ESP_LOGI("POWER", "DEEP_SLEEP: button to wake; battery=%umV", battery_mv);
#else
    ESP_ERROR_CHECK(esp_sleep_disable_wakeup_source(ESP_SLEEP_WAKEUP_ALL));
    ESP_LOGI("POWER", "DEEP_SLEEP: Feather Reset to restart; battery=%umV", battery_mv);
#endif
    esp_deep_sleep_start();
#else
    player_ui_notice("Sleep needs ANO wake wiring");
#endif
}
