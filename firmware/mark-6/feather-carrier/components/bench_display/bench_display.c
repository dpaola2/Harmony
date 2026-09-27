/* Native transport for Waveshare #29318 ST7796S. Font attribution: LICENSE-st7789. */
#include <string.h>
#include "bench_display.h"
#include "driver/gpio.h"
#include "driver/spi_master.h"
#include "esp_attr.h"
#include "carrier_board.h"
#include "st7796_init.h"
#include "esp_log.h"
#include "esp_rom_sys.h"
#include "sdkconfig.h"
#include "freertos/FreeRTOS.h"
#include "freertos/task.h"
#include "font8x16.h"

#define TRY(expr) do { esp_err_t err_ = (expr); if (err_ != ESP_OK) return err_; } while (0)
#define CS CARRIER_TFT_CS
#define DC CARRIER_TFT_DC
#define RST CARRIER_TFT_RST
#define WIDTH 320
#define HEIGHT 480
static spi_device_handle_t lcd;
static bool ready;
static DMA_ATTR uint8_t pixels[WIDTH * 8 * 2];

static esp_err_t send_bytes(const void *data, size_t len)
{
    if (!carrier_board_ready()) return ESP_ERR_INVALID_STATE;
    spi_transaction_t t = {.length = len * 8, .tx_buffer = data};
    return spi_device_transmit(lcd, &t);
}

static esp_err_t command(uint8_t cmd, const uint8_t *data, size_t len)
{
    TRY(spi_device_acquire_bus(lcd, portMAX_DELAY));
    gpio_set_level(CS, 0);
    gpio_set_level(DC, 0);
    esp_err_t err = send_bytes(&cmd, 1);
    gpio_set_level(DC, 1);
    if (err == ESP_OK && len) err = send_bytes(data, len);
    gpio_set_level(CS, 1);
    spi_device_release_bus(lcd);
    return err;
}

static esp_err_t window(int x, int y, int w, int h)
{
    /* ST7796S portrait: full 320 x 480 RAM, no cropped-panel offsets. */
    unsigned x0 = x, x1 = x0 + w - 1, y0 = y, y1 = y0 + h - 1;
    uint8_t cols[] = {x0 >> 8, x0, x1 >> 8, x1};
    uint8_t rows[] = {y0 >> 8, y0, y1 >> 8, y1};
    TRY(command(0x2a, cols, sizeof(cols)));
    TRY(command(0x2b, rows, sizeof(rows)));
    /* Hold bus ownership for the complete manual-CS pixel stream so an SD
     * task cannot clock the LCD while its CS is low. */
    TRY(spi_device_acquire_bus(lcd, portMAX_DELAY));
    gpio_set_level(CS, 0);
    gpio_set_level(DC, 0);
    uint8_t write_ram = 0x2c;
    esp_err_t err = send_bytes(&write_ram, 1);
    gpio_set_level(DC, 1);
    if (err != ESP_OK) { gpio_set_level(CS, 1); spi_device_release_bus(lcd); }
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
    }
    gpio_set_level(CS, 1);
    spi_device_release_bus(lcd);
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
    spi_device_release_bus(lcd);
    return err;
}

esp_err_t bench_display_blit(int x, int y, int w, int h, const uint16_t *data)
{
    if (!data || !ready || x < 0 || y < 0 || w <= 0 || h <= 0 || h > 8 ||
        x > WIDTH - w || y > HEIGHT - h) return ESP_ERR_INVALID_ARG;
    /* Stage the complete strip before taking the bus, then one DMA transfer. */
    for (int i = 0; i < w*h; ++i) {
        uint16_t c = data[i];
        pixels[i*2] = c >> 8; pixels[i*2+1] = c;
    }
    TRY(window(x, y, w, h));
    esp_err_t err = send_pixels(w*h);
    gpio_set_level(CS, 1);
    spi_device_release_bus(lcd);
    return err;
}

static esp_err_t display_init(bool existing_bus)
{
    if (!carrier_board_ready() || ready) return ESP_ERR_INVALID_STATE;
    spi_bus_config_t bus = {.mosi_io_num = CARRIER_TFT_MOSI, .miso_io_num = -1,
        .sclk_io_num = CARRIER_TFT_SCK, .quadwp_io_num = -1, .quadhd_io_num = -1,
        .max_transfer_sz = sizeof(pixels)};
    if (!existing_bus) TRY(spi_bus_initialize(SPI2_HOST, &bus, SPI_DMA_CH_AUTO));
    spi_device_interface_config_t dev = {.clock_speed_hz = 4000000, .mode = 0,
        .spics_io_num = -1, .queue_size = 1};
    TRY(spi_bus_add_device(SPI2_HOST, &dev, &lcd));
    gpio_set_level(RST, 1); vTaskDelay(pdMS_TO_TICKS(100));
    gpio_set_level(RST, 0); vTaskDelay(pdMS_TO_TICKS(100));
    gpio_set_level(RST, 1); vTaskDelay(pdMS_TO_TICKS(100));
    for (size_t i = 0; i < sizeof(st7796_init) / sizeof(st7796_init[0]); ++i) {
        TRY(command(st7796_init[i].cmd, st7796_init[i].data, st7796_init[i].count));
        if (st7796_init[i].delay_ms) vTaskDelay(pdMS_TO_TICKS(st7796_init[i].delay_ms));
    }
    ready = true;
    TRY(bench_display_fill(0, 0, WIDTH, HEIGHT, 0));
    TRY(gpio_set_level(CARRIER_TFT_LITE, 1));
    ESP_LOGI("DISPLAY", "ST7796S SPI2 4MHz 320x480; write completed, visual check required");
    return ESP_OK;
}

/* The caller owns the existing SPI2 bus and must initialize any SD card first.
 * Only one task may call the display API; bus ownership serializes SD transfers. */
esp_err_t bench_display_init_on_existing_bus(void) { return display_init(true); }
esp_err_t bench_display_init(void) { return display_init(false); }

esp_err_t bench_display_white_isolation(void)
{
    if (!ready) TRY(bench_display_init());
    return bench_display_fill(0, 0, WIDTH, HEIGHT, 0xffff);
}

esp_err_t bench_display_probe(void)
{
    TRY(bench_display_text(8, 8, "HARMONY MARK 6", 0xffff, 0));
    TRY(bench_display_text(8, 28, "ST7796S DISPLAY TEST", 0xffff, 0));
    TRY(bench_display_fill(0, 0, WIDTH, 1, 0xffff));
    TRY(bench_display_fill(0, HEIGHT-1, WIDTH, 1, 0xffff));
    TRY(bench_display_fill(0, 0, 1, HEIGHT, 0xffff));
    TRY(bench_display_fill(WIDTH-1, 0, 1, HEIGHT, 0xffff));
    const uint16_t colors[] = {0xf800, 0x07e0, 0x001f};
    const char *labels[] = {"R", "G", "B"};
    for (int i = 0; i < 3; i++) {
        TRY(bench_display_fill(8 + 104*i, 52, 96, 80, colors[i]));
        TRY(bench_display_text(52 + 104*i, 142, labels[i], 0xffff, 0));
    }
    ESP_LOGI("DISPLAY", "DRAW_COMPLETE: no display readback; visual confirmation required");
    return ESP_OK;
}
