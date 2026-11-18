/* ST7365P driver for the slab (HSPI, CS held low, DMA ping-pong pixels). */
#include <string.h>
#include "sdkconfig.h"
#include "st7365p.h"
#include "st7365p_init.h"
#include "slab_pins.h"
#include "driver/gpio.h"
#include "driver/spi_master.h"
#include "esp_heap_caps.h"
#include "esp_log.h"
#include "freertos/FreeRTOS.h"
#include "freertos/task.h"

#ifndef CONFIG_SLAB_LCD_SPI_HZ
#define CONFIG_SLAB_LCD_SPI_HZ 40000000
#endif
#ifndef CONFIG_SLAB_LCD_COL_OFFSET
#define CONFIG_SLAB_LCD_COL_OFFSET 0
#endif
#ifndef CONFIG_SLAB_LCD_ROW_OFFSET
#define CONFIG_SLAB_LCD_ROW_OFFSET 0
#endif
#define TRY(x) do { esp_err_t e_ = (x); if (e_ != ESP_OK) return e_; } while (0)

static spi_device_handle_t dev;
static uint8_t *buf[2];
static spi_transaction_t trans[2];
static st7365p_config_t config;
static bool ready, bus_up;
static uint32_t bytes_sent;

void st7365p_default_config(st7365p_config_t *cfg)
{
    *cfg = (st7365p_config_t){.clock_hz = CONFIG_SLAB_LCD_SPI_HZ, .madctl = CONFIG_SLAB_LCD_MADCTL,
        .col_offset = CONFIG_SLAB_LCD_COL_OFFSET, .row_offset = CONFIG_SLAB_LCD_ROW_OFFSET};
}

bool st7365p_ready(void) { return ready; }
uint32_t st7365p_bytes_sent(void) { return bytes_sent; }

/* Blocking send with DC set. Short data goes in the transaction itself. */
static esp_err_t send(const uint8_t *data, size_t len, int dc)
{
    gpio_set_level(SLAB_PIN_LCD_DC, dc);
    spi_transaction_t t = {.length = len * 8};
    if (len <= 4) { t.flags = SPI_TRANS_USE_TXDATA; memcpy(t.tx_data, data, len); }
    else { memcpy(buf[0], data, len); t.tx_buffer = buf[0]; }
    esp_err_t err = spi_device_polling_transmit(dev, &t);
    if (err == ESP_OK) bytes_sent += len;
    return err;
}

static esp_err_t command(uint8_t cmd, const uint8_t *data, size_t len)
{
    TRY(send(&cmd, 1, 0));
    return len ? send(data, len, 1) : ESP_OK;
}

static esp_err_t window(int x, int y, int w, int h)
{
    unsigned x0 = (unsigned)x + config.col_offset, x1 = x0 + (unsigned)w - 1;
    unsigned y0 = (unsigned)y + config.row_offset, y1 = y0 + (unsigned)h - 1;
    const uint8_t cols[] = {(uint8_t)(x0 >> 8), (uint8_t)x0, (uint8_t)(x1 >> 8), (uint8_t)x1};
    const uint8_t rows[] = {(uint8_t)(y0 >> 8), (uint8_t)y0, (uint8_t)(y1 >> 8), (uint8_t)y1};
    TRY(command(0x2A, cols, 4));
    TRY(command(0x2B, rows, 4));
    TRY(command(0x2C, NULL, 0));
    gpio_set_level(SLAB_PIN_LCD_DC, 1);   /* pixel data follows */
    return ESP_OK;
}

static bool in_bounds(int x, int y, int w, int h)
{
    return x >= 0 && y >= 0 && w > 0 && h > 0 && x <= ST7365P_WIDTH - w && y <= ST7365P_HEIGHT - h;
}

/* Streams w*h pixels. next() fills a buffer with up to `room` pixels, big-endian. */
typedef size_t (*fill_fn)(uint8_t *out, size_t room, void *ctx);
static esp_err_t stream(size_t pixels, fill_fn next, void *ctx)
{
    esp_err_t err = ESP_OK;
    int in_flight = 0, slot = 0;
    while ((pixels || in_flight) && err == ESP_OK) {
        if (pixels && in_flight < 2) {
            size_t n = next(buf[slot], ST7365P_CHUNK_BYTES / 2, ctx);
            if (n > pixels) n = pixels;
            trans[slot] = (spi_transaction_t){.length = n * 16, .tx_buffer = buf[slot]};
            err = spi_device_queue_trans(dev, &trans[slot], portMAX_DELAY);
            if (err != ESP_OK) break;
            bytes_sent += n * 2;
            pixels -= n;
            ++in_flight;
            slot ^= 1;
            continue;
        }
        spi_transaction_t *done;
        err = spi_device_get_trans_result(dev, &done, portMAX_DELAY);
        --in_flight;
    }
    /* Never leave a transfer queued on a buffer the next call reuses. */
    while (in_flight > 0) {
        spi_transaction_t *done;
        if (spi_device_get_trans_result(dev, &done, portMAX_DELAY) != ESP_OK) break;
        --in_flight;
    }
    return err;
}

typedef struct { const uint16_t *src; int stride, w, h, row, col; } blit_ctx_t;
static size_t blit_next(uint8_t *out, size_t room, void *p)
{
    blit_ctx_t *c = p;
    size_t n = 0;
    while (n < room && c->row < c->h) {
        const uint16_t *line = c->src + (size_t)c->row * c->stride;
        while (n < room && c->col < c->w) {
            uint16_t v = line[c->col++];
            out[2 * n] = (uint8_t)(v >> 8);
            out[2 * n + 1] = (uint8_t)v;
            ++n;
        }
        if (c->col == c->w) { c->col = 0; ++c->row; }
    }
    return n;
}

typedef struct { uint16_t color; size_t left; } fill_ctx_t;
static size_t fill_next(uint8_t *out, size_t room, void *p)
{
    fill_ctx_t *c = p;
    size_t n = room < c->left ? room : c->left;
    for (size_t i = 0; i < n; ++i) { out[2 * i] = (uint8_t)(c->color >> 8); out[2 * i + 1] = (uint8_t)c->color; }
    c->left -= n;
    return n;
}

esp_err_t st7365p_fill(int x, int y, int w, int h, uint16_t color)
{
    if (!ready) return ESP_ERR_INVALID_STATE;
    if (!in_bounds(x, y, w, h)) return ESP_ERR_INVALID_ARG;
    TRY(window(x, y, w, h));
    fill_ctx_t c = {.color = color, .left = (size_t)w * h};
    return stream((size_t)w * h, fill_next, &c);
}

esp_err_t st7365p_blit(int x, int y, int w, int h, const uint16_t *src, int stride)
{
    if (!ready) return ESP_ERR_INVALID_STATE;
    if (!src || stride < w || !in_bounds(x, y, w, h)) return ESP_ERR_INVALID_ARG;
    TRY(window(x, y, w, h));
    blit_ctx_t c = {.src = src, .stride = stride, .w = w, .h = h};
    return stream((size_t)w * h, blit_next, &c);
}

static esp_err_t output(int gpio, int level)
{
    gpio_set_level(gpio, level);
    gpio_config_t c = {.pin_bit_mask = 1ULL << gpio, .mode = GPIO_MODE_OUTPUT,
        .pull_up_en = GPIO_PULLUP_DISABLE, .pull_down_en = GPIO_PULLDOWN_DISABLE, .intr_type = GPIO_INTR_DISABLE};
    TRY(gpio_config(&c));
    return gpio_set_level(gpio, level);
}

esp_err_t st7365p_init(const st7365p_config_t *cfg)
{
    if (ready) return ESP_ERR_INVALID_STATE;
    config = *cfg;
    /* Touch rule 1: CS low for as long as the screen has power. */
    TRY(output(SLAB_PIN_LCD_CS, 0));
    TRY(output(SLAB_PIN_LCD_DC, 0));
    TRY(output(SLAB_PIN_LCD_RST, 0));
    spi_bus_config_t bus = {.mosi_io_num = SLAB_PIN_LCD_MOSI, .miso_io_num = -1,
        .sclk_io_num = SLAB_PIN_LCD_SCK, .quadwp_io_num = -1, .quadhd_io_num = -1,
        .max_transfer_sz = ST7365P_CHUNK_BYTES};
    TRY(spi_bus_initialize(SPI2_HOST, &bus, SPI_DMA_CH_AUTO));
    bus_up = true;
    /* Write-only and half duplex: on these GPIO-matrix pins IDF refuses full duplex
     * above about 26.7 MHz (it would need a read dummy cycle). */
    spi_device_interface_config_t d = {.clock_speed_hz = (int)cfg->clock_hz, .mode = 0,
        .spics_io_num = -1, .queue_size = 2, .flags = SPI_DEVICE_HALFDUPLEX};
    esp_err_t err = spi_bus_add_device(SPI2_HOST, &d, &dev);
    for (int i = 0; i < 2 && err == ESP_OK; ++i) {
        buf[i] = heap_caps_malloc(ST7365P_CHUNK_BYTES, MALLOC_CAP_DMA | MALLOC_CAP_INTERNAL);
        if (!buf[i]) err = ESP_ERR_NO_MEM;
    }
    if (err != ESP_OK) { st7365p_deinit(); return err; }
    /* The panel was held in reset while 3V3_PERIPH came up. */
    vTaskDelay(pdMS_TO_TICKS(ST7365P_RESET_LOW_MS));
    gpio_set_level(SLAB_PIN_LCD_RST, 1);
    vTaskDelay(pdMS_TO_TICKS(ST7365P_RESET_WAIT_MS));
    for (size_t i = 0; i < sizeof(st7365p_init_cmds) / sizeof(st7365p_init_cmds[0]) && err == ESP_OK; ++i) {
        st7365p_cmd_t c = st7365p_init_cmds[i];
        if (c.cmd == 0x36) c.data[0] = cfg->madctl;
        err = command(c.cmd, c.data, c.len);
        if (err == ESP_OK && c.delay_ms) vTaskDelay(pdMS_TO_TICKS(c.delay_ms));
    }
    if (err == ESP_OK) { ready = true; err = st7365p_fill(0, 0, ST7365P_WIDTH, ST7365P_HEIGHT, 0x0000); }
    if (err != ESP_OK) { st7365p_deinit(); return err; }
    ESP_LOGI("ST7365P", "320x320 RGB565, HSPI %u Hz, MADCTL 0x%02x, offsets %u/%u",
        (unsigned)cfg->clock_hz, cfg->madctl, cfg->col_offset, cfg->row_offset);
    return ESP_OK;
}

esp_err_t st7365p_sleep(void)
{
    if (!ready) return ESP_ERR_INVALID_STATE;
    TRY(command(0x28, NULL, 0));
    TRY(command(0x10, NULL, 0));
    vTaskDelay(pdMS_TO_TICKS(120));
    return ESP_OK;
}

void st7365p_deinit(void)
{
    ready = false;
    if (dev) { spi_bus_remove_device(dev); dev = NULL; }
    if (bus_up) { spi_bus_free(SPI2_HOST); bus_up = false; }
    for (int i = 0; i < 2; ++i) { heap_caps_free(buf[i]); buf[i] = NULL; }
}
