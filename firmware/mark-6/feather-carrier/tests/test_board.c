#include <assert.h>
#include <stdio.h>
#include <string.h>
#include "mock_idf.h"
#include "carrier_board.h"

static uint8_t actual[6] = {0x58, 0xaa, 0xbb, 0xcc, 0xdd, 0xef};
static uint32_t flash_bytes = 8 * 1024 * 1024;
static unsigned elapsed, input_configured, outputs, preloaded;
static int pg_mode; /* 0 low, 1 chatter, 2 stable high */
esp_err_t esp_read_mac(uint8_t mac[6], int kind) { memcpy(mac, actual, 6); return ESP_OK; }
esp_err_t esp_flash_get_size(void *chip, uint32_t *out) { *out = flash_bytes; return ESP_OK; }
size_t esp_psram_get_size(void) { return 2 * 1024 * 1024; }
void vTaskDelay(unsigned ticks) { elapsed += ticks; }
esp_err_t gpio_config(const gpio_config_t *cfg)
{
    assert(cfg->pin_bit_mask == 1ULL << CARRIER_PG);
    assert(cfg->mode == GPIO_MODE_INPUT && !cfg->pull_up_en && !cfg->pull_down_en);
    ++input_configured;
    return ESP_OK;
}
int gpio_get_level(int pin) { assert(pin == CARRIER_PG); return pg_mode == 2 || (pg_mode == 1 && elapsed % 25); }
esp_err_t gpio_set_level(int pin, int level)
{
    assert(pg_mode == 2 && elapsed >= 50);
    assert(pin == CARRIER_SD_CS || pin == CARRIER_TFT_CS || pin == CARRIER_TFT_RST ||
           pin == CARRIER_TFT_DC || pin == CARRIER_TFT_LITE);
    assert(level == (pin == CARRIER_SD_CS || pin == CARRIER_TFT_CS || pin == CARRIER_TFT_RST));
    ++preloaded;
    return ESP_OK;
}
esp_err_t gpio_set_direction(int pin, int direction)
{
    assert(direction == GPIO_MODE_OUTPUT && preloaded == outputs + 1);
    ++outputs;
    return ESP_OK;
}
int main(void)
{
    assert(carrier_board_init() == ESP_ERR_INVALID_STATE);
    assert(!input_configured && !outputs);
    actual[5] = 0xee; flash_bytes = 4 * 1024 * 1024;
    assert(carrier_board_init() == ESP_ERR_INVALID_STATE);
    assert(!input_configured && !outputs);
    flash_bytes = 8 * 1024 * 1024;
    assert(carrier_board_init() == ESP_ERR_TIMEOUT);
    assert(elapsed == 2000 && !outputs);
    pg_mode = 1; elapsed = 0;
    assert(carrier_board_init() == ESP_ERR_TIMEOUT);
    assert(!outputs);
    pg_mode = 2; elapsed = 0;
    assert(carrier_board_init() == ESP_OK);
    assert(elapsed == 50 && outputs == 5 && carrier_board_ready());
    pg_mode = 0;
    assert(!carrier_board_ready());
    puts("PASS actual board startup: identity/memory rejection, low/chattering PG, latch ordering, PG loss");
}
