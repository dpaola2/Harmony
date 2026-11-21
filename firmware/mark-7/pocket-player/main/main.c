#include "sdkconfig.h"
#include "esp_log.h"
#include "nvs_flash.h"
#include "esp_bt.h"
#include "esp_bt_main.h"
#include "esp_gap_bt_api.h"
#include "audio_player.h"
#include "player_display.h"
#include "player_bluetooth.h"
#include "carrier_board.h"
#include "carrier_controls.h"
#include "bench_display.h"
#include "bench_storage.h"
#include <dirent.h>
#include <stdio.h>
#include <sys/stat.h>
#define BT_AV_TAG "MARK7"
#ifndef CONFIG_CARRIER_DISPLAY_ONLY
#define CONFIG_CARRIER_DISPLAY_ONLY 0
#endif
void app_main(void)
{
    if (carrier_board_init() != ESP_OK) return;
#if CONFIG_MARK7_STORAGE_TEST
    esp_err_t sd_err = bench_storage_mount();
    if (sd_err == ESP_OK) {
        const char *paths[] = {"/sd", "/sd/HARMONY"};
        for (unsigned i = 0; i < 2; ++i) {
            DIR *dir = opendir(paths[i]);
            if (!dir) { ESP_LOGW(BT_AV_TAG, "Cannot list %s", paths[i]); continue; }
            struct dirent *entry;
            unsigned count = 0;
            bool sampled = false;
            while (count < 32 && (entry = readdir(dir))) {
                if (entry->d_name[0] == '.') continue;
                ++count;
                ESP_LOGI(BT_AV_TAG, "SD_ENTRY %s/%s", paths[i], entry->d_name);
                char path[512];
                int n = snprintf(path, sizeof(path), "%s/%s", paths[i], entry->d_name);
                struct stat st;
                if (!sampled && n > 0 && n < sizeof(path) && stat(path, &st) == 0 && S_ISREG(st.st_mode)) {
                    FILE *file = fopen(path, "rb");
                    if (file) {
                        unsigned char bytes[512];
                        size_t got = fread(bytes, 1, sizeof(bytes), file);
                        ESP_LOGI(BT_AV_TAG, "SD_READ %s bytes=%u error=%d", path, (unsigned)got, ferror(file));
                        fclose(file);
                        sampled = true;
                    } else ESP_LOGE(BT_AV_TAG, "SD_OPEN failed: %s", path);
                }
            }
            closedir(dir);
        }
    }
    esp_err_t lcd_err = sd_err == ESP_OK ? bench_display_init_on_existing_bus() : bench_display_init_without_storage();
    if (lcd_err == ESP_OK) {
        lcd_err = bench_display_probe();
        if (lcd_err == ESP_OK)
            lcd_err = bench_display_text(8, 180, sd_err == ESP_OK ? "SD CARD MOUNTED" : "SD CARD FAILED", 0xffff, 0);
    }
    ESP_LOGI(BT_AV_TAG, "Storage test: SD=%s LCD=%s; Bluetooth remains off", esp_err_to_name(sd_err), esp_err_to_name(lcd_err));
    return;
#endif
    if (CONFIG_CARRIER_DISPLAY_ONLY) {
        /* Player builds alias bench_display_init to the shared SD bus path.
         * This mode has no storage, so it must initialize SPI itself. */
        esp_err_t err = bench_display_init_without_storage();
        if (err == ESP_OK) err = bench_display_probe();
        ESP_LOGI(BT_AV_TAG, "Display-only write result: %s; visual check required", esp_err_to_name(err));
        return;
    }
    /* Preferences and Bluetooth bonds share NVS; do not erase them on recovery. */
    esp_err_t ret = nvs_flash_init();
#ifdef HARMONY_PLAYER_UI
    if (ret != ESP_OK)
        ESP_LOGE(BT_AV_TAG, "NVS unavailable (%s); preferences cannot be saved", esp_err_to_name(ret));
    if (!audio_player_prepare())
        ESP_LOGE(BT_AV_TAG, "Library unavailable; starting recovery UI");
    audio_player_set_paused(true);
#else
    if (ret == ESP_ERR_NVS_NO_FREE_PAGES || ret == ESP_ERR_NVS_NEW_VERSION_FOUND) {
        ESP_ERROR_CHECK(nvs_flash_erase());
        ret = nvs_flash_init();
    }
    ESP_ERROR_CHECK(ret);
    ESP_LOGI(BT_AV_TAG, "MARK6_FEATHER_ALBUM target=%s playlist=HARMONY/ALBUM.M3U", remote_device_name);
    if (!audio_player_prepare()) {
        ESP_LOGE(BT_AV_TAG, "Audio preparation failed; Bluetooth will remain off");
        return;
    }
#endif
    if (!player_display_start()) {
        audio_player_stop();
        ESP_LOGE(BT_AV_TAG, "Display preparation failed; integration test not started");
        return;
    }
#if CONFIG_MARK7_WHEEL_INPUT || CONFIG_MARK7_ANO_INPUT
    if (carrier_controls_start() != ESP_OK)
        ESP_LOGW(BT_AV_TAG, "Controls unavailable; continuing audio/display bench");
#endif
    /*
     * This example only uses the functions of Classical Bluetooth.
     * So release the controller memory for Bluetooth Low Energy.
     */
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
    /* set default parameters for Secure Simple Pairing */
    esp_bt_sp_param_t param_type = ESP_BT_SP_IOCAP_MODE;
    esp_bt_io_cap_t iocap = ESP_BT_IO_CAP_NONE;
    esp_bt_gap_set_security_param(param_type, &iocap, sizeof(uint8_t));
#endif

    /*
     * Set default parameters for Legacy Pairing
     * Use variable pin, input pin code when pairing
     */
    esp_bt_pin_type_t pin_type = ESP_BT_PIN_TYPE_VARIABLE;
    esp_bt_pin_code_t pin_code;
    esp_bt_gap_set_pin(pin_type, 0, pin_code);

    #ifdef HARMONY_PLAYER_UI
    if (!player_bluetooth_init())
        ESP_LOGE(BT_AV_TAG, "Bluetooth manager failed to start; UI remains available");
    #else
    char bda_str[18] = {0};
    ESP_LOGI(BT_AV_TAG, "Own address:[%s]", bda2str((uint8_t *)esp_bt_dev_get_address(), bda_str, sizeof(bda_str)));
    bt_app_task_start_up();
    /* Bluetooth device name, connection mode and profile set up */
    bt_app_work_dispatch(bt_av_hdl_stack_evt, BT_APP_STACK_UP_EVT, NULL, 0, NULL);
    #endif
}
