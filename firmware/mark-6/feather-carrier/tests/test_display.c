#include <assert.h>
#include <limits.h>
#include <stdio.h>
#include <string.h>
#include "mock_idf.h"
#include "carrier_board.h"
#include "bench_display.h"

#ifdef TEST_SHARED_BUS
#define bench_display_init bench_display_init_on_existing_bus
#define EXPECTED_BUS_COUNT 0
#else
#define EXPECTED_BUS_COUNT 1
#endif
static bool powered, inject_error, bus_owned;
static bool acquire_error, pixel_error, write_command_error;
static unsigned transactions, pixel_bytes, bus_count;
static uint8_t current_command, column[4], row[4], last_pixel[2];
static uint8_t commands[64], format, orientation;
static unsigned command_count, delayed_ms;
static int levels[40];
bool carrier_board_ready(void) { return powered; }
esp_err_t gpio_set_level(int pin, int level)
{
    if (pin == CARRIER_TFT_LITE && level) assert(pixel_bytes == 320 * 480 * 2);
    if (pin == CARRIER_TFT_CS && !level) assert(bus_owned);
    levels[pin] = level;
    return ESP_OK;
}
esp_err_t spi_device_acquire_bus(spi_device_handle_t device, unsigned wait)
{
    assert(!bus_owned && wait == portMAX_DELAY);
    if (acquire_error) return ESP_ERR_TIMEOUT;
    bus_owned = true;
    return ESP_OK;
}
void spi_device_release_bus(spi_device_handle_t device)
{
    assert(bus_owned && levels[CARRIER_TFT_CS]);
    bus_owned = false;
}
void vTaskDelay(unsigned ticks) { delayed_ms += ticks; }
esp_err_t spi_bus_initialize(int host, const spi_bus_config_t *cfg, int dma)
{
    assert(host == SPI2_HOST && cfg->mosi_io_num == 27 && cfg->sclk_io_num == 14);
    assert(cfg->miso_io_num == -1); ++bus_count; return ESP_OK;
}
esp_err_t spi_bus_add_device(int host, const spi_device_interface_config_t *cfg, spi_device_handle_t *out)
{
    assert(host == SPI2_HOST && cfg->clock_speed_hz == 4000000 && cfg->spics_io_num == -1);
    *out = (void *)1; return ESP_OK;
}
esp_err_t spi_device_transmit(spi_device_handle_t dev, spi_transaction_t *t)
{
    assert(bus_owned && powered && !levels[CARRIER_TFT_CS] && t->length % 8 == 0);
    ++transactions;
    if (inject_error) return ESP_ERR_TIMEOUT;
    const uint8_t *b = t->tx_buffer;
    size_t n = t->length / 8;
    if (!levels[CARRIER_TFT_DC]) {
        assert(n == 1); current_command = *b;
        if (write_command_error && *b == 0x2c) return ESP_ERR_TIMEOUT;
        if (command_count < sizeof(commands)) commands[command_count] = *b;
        ++command_count;
    }
    else if (current_command == 0x3a) { assert(n == 1); format = *b; }
    else if (current_command == 0x36) { assert(n == 1); orientation = *b; }
    else if (current_command == 0x2a) { assert(n == 4); memcpy(column, b, 4); }
    else if (current_command == 0x2b) { assert(n == 4); memcpy(row, b, 4); }
    else if (current_command == 0x2c) {
        if (pixel_error) return ESP_ERR_TIMEOUT;
        assert(n <= 5120 && n % 2 == 0);
        pixel_bytes += n;
        if (n >= 2) memcpy(last_pixel, b + n - 2, 2);
    }
    return ESP_OK;
}
int main(void)
{
    assert(bench_display_init() == ESP_ERR_INVALID_STATE && bus_count == 0);
    powered = true;
    assert(bench_display_init() == ESP_OK && bus_count == EXPECTED_BUS_COUNT);
    const uint8_t expected[] = {0x11,0x36,0x3a,0xf0,0xf0,0xb4,0xb7,0xc0,0xc1,
        0xc2,0xc5,0xe8,0xe0,0xe1,0xf0,0xf0,0x21,0x29,0x2a,0x2b,0x2c};
    assert(command_count == sizeof(expected) && !memcmp(commands, expected, sizeof(expected)));
    assert(format == 0x05 && orientation == 0x48 && delayed_ms == 540);
    assert(pixel_bytes == 307200 && levels[CARRIER_TFT_LITE]);
    assert(!memcmp(column, (uint8_t[]){0,0,1,63}, 4));
    assert(!memcmp(row, (uint8_t[]){0,0,1,223}, 4));
    unsigned before = transactions;
    assert(bench_display_fill(-1, 0, 1, 1, 0) == ESP_ERR_INVALID_ARG);
    assert(bench_display_fill(319, 479, 2, 1, 0) == ESP_ERR_INVALID_ARG);
    assert(bench_display_fill(0, 0, INT_MAX, 1, 0) == ESP_ERR_INVALID_ARG);
    assert(bench_display_text(0, 465, "bad", 0, 0) == ESP_ERR_INVALID_ARG);
    assert(transactions == before);
    assert(bench_display_fill(319, 479, 1, 1, 0xf800) == ESP_OK);
    assert(!memcmp(column, (uint8_t[]){1,63,1,63}, 4));
    assert(!memcmp(row, (uint8_t[]){1,223,1,223}, 4));
    assert(last_pixel[0] == 0xf8 && last_pixel[1] == 0x00);
    unsigned pixels_before = pixel_bytes;
    assert(bench_display_text(312, 464, "clipped", 0xffff, 0) == ESP_OK);
    assert(pixel_bytes - pixels_before == 8 * 16 * 2);
    assert(bench_display_probe() == ESP_OK);
    const uint16_t strip[] = {0xf800, 0x07e0, 0x001f, 0xffff};
    pixels_before = pixel_bytes;
    assert(bench_display_blit(318, 478, 2, 2, strip) == ESP_OK);
    assert(pixel_bytes - pixels_before == 8 && last_pixel[0] == 0xff && last_pixel[1] == 0xff);
    assert(bench_display_blit(0, 0, 2, 9, strip) == ESP_ERR_INVALID_ARG);
    assert(bench_display_blit(319, 0, 2, 2, strip) == ESP_ERR_INVALID_ARG);
    assert(bench_display_blit(0, 0, 2, 2, NULL) == ESP_ERR_INVALID_ARG);
    uint16_t full_strip[320*8];
    for (unsigned i=0;i<320*8;i++) full_strip[i]=(uint16_t)i;
    pixels_before=pixel_bytes;
    assert(bench_display_blit(0, 0, 320, 8, full_strip) == ESP_OK);
    assert(pixel_bytes-pixels_before==5120 && last_pixel[0]==9 && last_pixel[1]==255);
    assert(!bus_owned);
    acquire_error = true;
    assert(bench_display_fill(0, 0, 1, 1, 0) == ESP_ERR_TIMEOUT);
    assert(!bus_owned && levels[CARRIER_TFT_CS]);
    acquire_error = false;
    pixel_error = true;
    assert(bench_display_blit(0, 0, 2, 2, strip) == ESP_ERR_TIMEOUT);
    assert(!bus_owned && levels[CARRIER_TFT_CS]);
    assert(bench_display_fill(0, 0, 2, 2, 0) == ESP_ERR_TIMEOUT);
    assert(!bus_owned && levels[CARRIER_TFT_CS]);
    pixel_error = false;
    write_command_error = true;
    assert(bench_display_fill(0, 0, 2, 2, 0) == ESP_ERR_TIMEOUT);
    assert(!bus_owned && levels[CARRIER_TFT_CS]);
    write_command_error = false;
    inject_error = true;
    assert(bench_display_fill(0, 0, 1, 1, 0) == ESP_ERR_TIMEOUT);
    assert(levels[CARRIER_TFT_CS] == 1 && !bus_owned);
    before = transactions; powered = false;
    assert(bench_display_fill(0, 0, 1, 1, 0) == ESP_ERR_INVALID_STATE);
    assert(transactions == before && levels[CARRIER_TFT_CS] == 1);
    puts("PASS actual display driver: full RAM bounds, clipping, RGB565, backlight sequence, error/PG handling");
}
