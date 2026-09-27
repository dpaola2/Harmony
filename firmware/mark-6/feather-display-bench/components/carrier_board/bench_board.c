#include <string.h>
#include "carrier_board.h"
#include "driver/gpio.h"
#include "esp_flash.h"
#include "esp_log.h"
#include "esp_mac.h"
#include "esp_psram.h"

static bool ready;
static const uint8_t expected_mac[6] = {0x14,0x33,0x5c,0x99,0x1a,0x28};
#define TRY(x) do { esp_err_t e = (x); if (e != ESP_OK) return e; } while (0)

bool carrier_board_ready(void) { return ready; }

esp_err_t carrier_board_init(void)
{
    uint8_t mac[6];
    uint32_t flash_size = 0;
    TRY(esp_read_mac(mac, ESP_MAC_WIFI_STA));
    TRY(esp_flash_get_size(NULL, &flash_size));
    if (memcmp(mac, expected_mac, sizeof mac) || flash_size != 8*1024*1024 ||
        !esp_psram_is_initialized() || esp_psram_get_size() != 2*1024*1024)
        return ESP_ERR_INVALID_STATE;
    // Both chip selects inactive before shared SPI initialization.
    const int pins[] = {CARRIER_SD_CS,CARRIER_TFT_CS,CARRIER_TFT_RST,CARRIER_TFT_DC,CARRIER_TFT_LITE};
    const int levels[] = {1,1,1,0,0};
    for (unsigned i=0;i<sizeof pins/sizeof pins[0];i++) {
        TRY(gpio_set_level(pins[i],levels[i]));
        TRY(gpio_set_direction(pins[i],GPIO_MODE_OUTPUT));
    }
    ready = true;
    ESP_LOGI("LCD_BENCH", "Identity and capacities matched; LCD/SD control outputs enabled");
    return ESP_OK;
}
