#include <string.h>
#include "carrier_policy.h"
#include "sdkconfig.h"
#include "carrier_board.h"
#include "driver/gpio.h"
#include "driver/rtc_io.h"
#include "esp_flash.h"
#include "esp_log.h"
#include "esp_mac.h"
#include "esp_psram.h"
#include "freertos/FreeRTOS.h"
#include "freertos/task.h"
#ifndef CONFIG_MARK7_ANO_INPUT
#define CONFIG_MARK7_ANO_INPUT 0
#endif

static bool ready;
static const uint8_t demo_mac[6] = {0x14,0x33,0x5c,0x99,0x1a,0x28};
#define TRY(x) do { esp_err_t e = (x); if (e != ESP_OK) return e; } while (0)

bool carrier_board_ready(void) { return ready; }

esp_err_t carrier_board_init(void)
{
    uint8_t mac[6];
    uint32_t flash_size = 0;
    TRY(esp_read_mac(mac, ESP_MAC_WIFI_STA));
    TRY(esp_flash_get_size(NULL, &flash_size));
    ESP_LOGI("MARK7", "Feather STA MAC %02x:%02x:%02x:%02x:%02x:%02x", mac[0],mac[1],mac[2],mac[3],mac[4],mac[5]);
    if (!carrier_mac_matches(CONFIG_CARRIER_EXPECTED_MAC, mac) || !memcmp(mac, demo_mac, 6) || flash_size != 8*1024*1024 ||
        !esp_psram_is_initialized() || esp_psram_get_size() != 2*1024*1024)
        { ESP_LOGE("MARK7", "Uncommissioned/wrong board; peripheral outputs remain disabled"); return ESP_ERR_INVALID_STATE; }
    rtc_gpio_deinit(GPIO_NUM_34);
    rtc_gpio_hold_dis(GPIO_NUM_2);
    rtc_gpio_deinit(GPIO_NUM_2);
    gpio_deep_sleep_hold_dis();
    gpio_hold_dis(CARRIER_TFT_LITE);
    gpio_hold_dis(CARRIER_TFT_CS);
    gpio_hold_dis(CARRIER_SD_CS);
    // Both chip selects inactive before shared SPI initialization.
    const int pins[] = {CARRIER_SD_CS,CARRIER_TFT_CS,CARRIER_TFT_RST,CARRIER_TFT_DC,CARRIER_TFT_LITE};
    const int levels[] = {1,1,1,0,0};
    for (unsigned i=0;i<sizeof pins/sizeof pins[0];i++) {
        TRY(gpio_set_level(pins[i],levels[i]));
        TRY(gpio_set_direction(pins[i],GPIO_MODE_OUTPUT));
    }
    // The ANO uses the Feather's switched STEMMA QT supply.
    TRY(gpio_set_level(2, CONFIG_MARK7_ANO_INPUT ? 1 : 0));
    TRY(gpio_set_direction(2, GPIO_MODE_OUTPUT));
    if (CONFIG_MARK7_ANO_INPUT) vTaskDelay(pdMS_TO_TICKS(100));
    ready = true;
    ESP_LOGI("LCD_BENCH", "Identity and capacities matched; LCD/SD control outputs enabled");
    return ESP_OK;
}
