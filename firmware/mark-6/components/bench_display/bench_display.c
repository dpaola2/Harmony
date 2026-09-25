/* ST7789 init/geometry and font adapted from Russ Hughes' pinned Mark-5 driver.
 * See LICENSE-st7789 and source-lock.json. Transport is native ESP-IDF SPI.
 */
#include <string.h>
#include "bench_display.h"
#include "driver/gpio.h"
#include "driver/spi_master.h"
#include "esp_attr.h"
#include "esp_mac.h"
#include "esp_log.h"
#include "esp_rom_sys.h"
#include "sdkconfig.h"
#include "freertos/FreeRTOS.h"
#include "freertos/task.h"
#include "font8x16.h"

#define TRY(expr) do { esp_err_t err_ = (expr); if (err_ != ESP_OK) return err_; } while (0)
#define CS 26
#define DC 33
#define RST 32
#define WIDTH 240
#define HEIGHT 135
#if !CONFIG_BENCH_DISPLAY_SOFT_SPI
static spi_device_handle_t lcd;
#endif
static bool ready;
static DMA_ATTR uint8_t pixels[WIDTH * 2];

static esp_err_t send_bytes(const void *data, size_t len)
{
#if CONFIG_BENCH_DISPLAY_SOFT_SPI
    const uint8_t *bytes = data;
    for (size_t i = 0; i < len; i++) {
        for (int bit = 7; bit >= 0; bit--) {
            gpio_set_level(14, 0);
            gpio_set_level(13, (bytes[i] >> bit) & 1);
            esp_rom_delay_us(2);
            gpio_set_level(14, 1);
            esp_rom_delay_us(2);
        }
    }
    gpio_set_level(14, 0);
    return ESP_OK;
#else
    spi_transaction_t t = {.length = len * 8, .tx_buffer = data};
    return spi_device_transmit(lcd, &t);
#endif
}

static esp_err_t command(uint8_t cmd, const uint8_t *data, size_t len)
{
    gpio_set_level(CS, 0);
    gpio_set_level(DC, 0);
    esp_err_t err = send_bytes(&cmd, 1);
    gpio_set_level(DC, 1);
    if (err == ESP_OK && len) err = send_bytes(data, len);
    gpio_set_level(CS, 1);
    return err;
}

static esp_err_t window(int x, int y, int w, int h)
{
    /* Landscape rotation 1 and panel offsets from the verified Mark-5 driver. */
    unsigned x0 = x + 40, x1 = x0 + w - 1, y0 = y + 53, y1 = y0 + h - 1;
    uint8_t cols[] = {x0 >> 8, x0, x1 >> 8, x1};
    uint8_t rows[] = {y0 >> 8, y0, y1 >> 8, y1};
    TRY(command(0x2a, cols, sizeof(cols)));
    TRY(command(0x2b, rows, sizeof(rows)));
    /* Preserve the successful isolation test's CS behavior for each rectangle. */
    gpio_set_level(CS, 0);
    gpio_set_level(DC, 0);
    uint8_t write_ram = 0x2c;
    esp_err_t err = send_bytes(&write_ram, 1);
    gpio_set_level(DC, 1);
    if (err != ESP_OK) gpio_set_level(CS, 1);
    return err;
}

static esp_err_t send_pixels(size_t count)
{
    return send_bytes(pixels, count * 2);
}

esp_err_t bench_display_fill(int x, int y, int w, int h, uint16_t color)
{
    if (!ready || x < 0 || y < 0 || w <= 0 || h <= 0 || x > WIDTH - w || y > HEIGHT - h)
        return ESP_ERR_INVALID_ARG;
    TRY(window(x, y, w, h));
    for (int i = 0; i < w; i++) { pixels[2*i] = color >> 8; pixels[2*i+1] = color; }
    esp_err_t err = ESP_OK;
    for (int i = 0; i < h && err == ESP_OK; i++) {
        err = send_pixels(w);
#if CONFIG_BENCH_DISPLAY_SOFT_SPI
        if (i % 8 == 7) vTaskDelay(1);
#endif
    }
    gpio_set_level(CS, 1);
    return err;
}

esp_err_t bench_display_text(int x, int y, const char *text, uint16_t fg, uint16_t bg)
{
    if (!text || !ready || x < 0 || y < 0 || x >= WIDTH || y > HEIGHT - 16)
        return ESP_ERR_INVALID_ARG;
    size_t n = strnlen(text, (WIDTH - x) / 8);
    if (!n) return ESP_OK;
    TRY(window(x, y, n * 8, 16));
    esp_err_t err = ESP_OK;
    for (int row = 0; row < 16 && err == ESP_OK; row++) {
        for (size_t i = 0; i < n; i++) {
            unsigned ch = (unsigned char)text[i];
            if (ch < 32 || ch > 127) ch = '?';
            uint8_t bits = font8x16[(ch - 32) * 16 + row];
            for (int bit = 0; bit < 8; bit++) {
                uint16_t color = (bits & (0x80 >> bit)) ? fg : bg;
                size_t off = (i * 8 + bit) * 2;
                pixels[off] = color >> 8; pixels[off+1] = color;
            }
        }
        err = send_pixels(n * 8);
    }
    gpio_set_level(CS, 1);
    return err;
}

static esp_err_t setup_bus(void)
{
    const uint8_t expected[] = {0x5c, 0x01, 0x3b, 0x89, 0x24, 0x04};
    uint8_t mac[6];
    TRY(esp_read_mac(mac, ESP_MAC_WIFI_STA));
    if (memcmp(mac, expected, sizeof(mac))) return ESP_ERR_INVALID_STATE;
    gpio_config_t gp = {.pin_bit_mask = (1ULL << CS) | (1ULL << DC) | (1ULL << RST),
                        .mode = GPIO_MODE_OUTPUT};
    TRY(gpio_config(&gp));
    gpio_set_level(CS, 1);
    gpio_set_level(RST, 1);
#if CONFIG_BENCH_DISPLAY_SOFT_SPI
    gpio_config_t spi_gpio = {.pin_bit_mask = (1ULL << 14) | (1ULL << 13),
                             .mode = GPIO_MODE_OUTPUT};
    TRY(gpio_config(&spi_gpio));
    gpio_set_level(14, 0);
    gpio_set_level(13, 0);
#else
    spi_bus_config_t bus = {.mosi_io_num = 13, .miso_io_num = -1, .sclk_io_num = 14,
        .quadwp_io_num = -1, .quadhd_io_num = -1, .max_transfer_sz = sizeof(pixels)};
    TRY(spi_bus_initialize(SPI2_HOST, &bus, SPI_DMA_CH_AUTO));
    spi_device_interface_config_t dev = {.clock_speed_hz = 250000, .mode = 0,
        .spics_io_num = -1, .queue_size = 1};
    TRY(spi_bus_add_device(SPI2_HOST, &dev, &lcd));
#endif
    ready = true;
    return ESP_OK;
}

static esp_err_t minimal_init(uint8_t madctl)
{
    TRY(setup_bus());
    gpio_set_level(RST, 0); vTaskDelay(pdMS_TO_TICKS(100));
    gpio_set_level(RST, 1); vTaskDelay(pdMS_TO_TICKS(150));
    TRY(command(0x01, NULL, 0)); vTaskDelay(pdMS_TO_TICKS(150));
    TRY(command(0x11, NULL, 0)); vTaskDelay(pdMS_TO_TICKS(150));
    uint8_t format = 0x55;
    TRY(command(0x3a, &format, 1));
    TRY(command(0x36, &madctl, 1));
    TRY(command(0x21, NULL, 0));
    TRY(command(0x13, NULL, 0));
    TRY(command(0x29, NULL, 0)); vTaskDelay(pdMS_TO_TICKS(100));
    return ESP_OK;
}

esp_err_t bench_display_init(void)
{
    TRY(minimal_init(0x68)); /* landscape 1, BGR */
    ESP_LOGI("DISPLAY", "READY %s SCK14 MOSI13 CS26 DC33 RST32; 240x135 BGR",
#if CONFIG_BENCH_DISPLAY_SOFT_SPI
             "software SPI, 2us half-cycle"
#else
             "SPI2 250kHz"
#endif
    );
    return bench_display_fill(0, 0, WIDTH, HEIGHT, 0);
}

esp_err_t bench_display_white_isolation(void)
{
    /* Reproduce the successful September 19 Mark-5 isolation script:
     * hard reset, software reset, minimal init, then CS held through all RAM.
     */
    TRY(minimal_init(0x00));
    const uint8_t cols[] = {0, 0, 0, 239};
    const uint8_t rows[] = {0, 0, 1, 63};
    TRY(command(0x2a, cols, sizeof(cols)));
    TRY(command(0x2b, rows, sizeof(rows)));
    gpio_set_level(CS, 0);
    gpio_set_level(DC, 0);
    uint8_t write_ram = 0x2c;
    esp_err_t err = send_bytes(&write_ram, 1);
    gpio_set_level(DC, 1);
    memset(pixels, 0xff, sizeof(pixels));
    for (int row = 0; row < 320 && err == ESP_OK; row++) {
        err = send_bytes(pixels, sizeof(pixels));
        if (row % 8 == 7) vTaskDelay(1);
    }
    gpio_set_level(CS, 1);
    TRY(err);
    ESP_LOGI("DISPLAY", "MARK5_REPLAY_WHITE_COMPLETE minimal init, CS held through 240x320 RAM; visual check required");
    return ESP_OK;
}

esp_err_t bench_display_probe(void)
{
    TRY(bench_display_text(8, 8, "HARMONY MARK 6", 0xffff, 0));
    TRY(bench_display_text(8, 28, "DISPLAY TEST", 0xffff, 0));
    TRY(bench_display_fill(0, 0, WIDTH, 1, 0xffff));
    TRY(bench_display_fill(0, HEIGHT-1, WIDTH, 1, 0xffff));
    TRY(bench_display_fill(0, 0, 1, HEIGHT, 0xffff));
    TRY(bench_display_fill(WIDTH-1, 0, 1, HEIGHT, 0xffff));
    const uint16_t colors[] = {0xf800, 0x07e0, 0x001f};
    const char *labels[] = {"R", "G", "B"};
    for (int i = 0; i < 3; i++) {
        TRY(bench_display_fill(4 + 78*i, 52, 76, 38, colors[i]));
        TRY(bench_display_text(38 + 78*i, 96, labels[i], 0xffff, 0));
    }
    ESP_LOGI("DISPLAY", "DRAW_COMPLETE: visual confirmation required");
    return ESP_OK;
}
