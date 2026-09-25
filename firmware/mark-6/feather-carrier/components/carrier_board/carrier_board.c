#include "carrier_board.h"
#include "carrier_policy.h"
#include "driver/gpio.h"
#include "esp_mac.h"
#include "esp_log.h"
#include "esp_flash.h"
#include "esp_psram.h"
#include "sdkconfig.h"
#include "freertos/FreeRTOS.h"
#include "freertos/task.h"

static bool ready;
#define TRY(x) do { esp_err_t e = (x); if (e != ESP_OK) return e; } while (0)

bool carrier_board_ready(void)
{
    return ready && gpio_get_level(CARRIER_PG);
}

esp_err_t carrier_board_init(void)
{
    uint8_t mac[6];
    uint32_t flash_size = 0;
    TRY(esp_read_mac(mac, ESP_MAC_WIFI_STA));
    ESP_LOGI("CARRIER", "Identity %02x:%02x:%02x:%02x:%02x:%02x", MAC2STR(mac));
    if (!carrier_mac_matches(CONFIG_CARRIER_EXPECTED_MAC, mac)) {
        ESP_LOGE("CARRIER", "Uncommissioned or wrong board; application peripheral GPIO unchanged");
        return ESP_ERR_INVALID_STATE;
    }
    TRY(esp_flash_get_size(NULL, &flash_size));
    if (flash_size != 8 * 1024 * 1024 || esp_psram_get_size() != 2 * 1024 * 1024) {
        ESP_LOGE("CARRIER", "Expected Feather V2 8MB flash / 2MB PSRAM");
        return ESP_ERR_INVALID_STATE;
    }
    gpio_config_t pg = {.pin_bit_mask = 1ULL << CARRIER_PG, .mode = GPIO_MODE_INPUT,
        .pull_up_en = GPIO_PULLUP_DISABLE, .pull_down_en = GPIO_PULLDOWN_DISABLE};
    TRY(gpio_config(&pg));
    unsigned samples = 0;
    for (unsigned i = 0; i < 400; ++i) {
        vTaskDelay(pdMS_TO_TICKS(5));
        if (carrier_pg_sample(&samples, gpio_get_level(CARRIER_PG))) {
            /* Preload the output latch before enabling outputs. Other bus pins
             * remain inputs until their respective drivers initialize. */
            const int pins[] = {CARRIER_SD_CS, CARRIER_TFT_CS, CARRIER_TFT_RST,
                                CARRIER_TFT_DC, CARRIER_TFT_LITE};
            const int levels[] = {1, 1, 1, 0, 0};
            for (unsigned j = 0; j < sizeof(pins) / sizeof(pins[0]); ++j) {
                TRY(gpio_set_level(pins[j], levels[j]));
                TRY(gpio_set_direction(pins[j], GPIO_MODE_OUTPUT));
            }
            ready = true;
            ESP_LOGI("CARRIER", "PG stable; peripheral initialization enabled");
            return ESP_OK;
        }
    }
    ESP_LOGE("CARRIER", "PG timeout; peripheral outputs remain disabled");
    return ESP_ERR_TIMEOUT;
}
