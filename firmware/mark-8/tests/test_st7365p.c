/* ST7365P driver against SPI and GPIO mocks. Prints the init sequence as it
 * reaches the wire ("INIT ..." lines); tests/verify.py compares it with the
 * vendor file. */
#include <assert.h>
#include <stdio.h>
#include <string.h>
#include "mock_idf.h"
#include "slab_pins.h"
#include "st7365p.h"

static int level[40], configured_output[40];
static bool cs_ever_high, bus_init, device_added;
static int spics = 99, clock_hz, queue_size, max_transfer;
static unsigned delays, in_flight, max_in_flight, queued_total;
static void *dma_bufs[4];
static unsigned dma_count;
static spi_transaction_t *queue[4];
static unsigned q_head, q_tail;
static bool fail_pixels;
/* Wire log: command bytes and their parameters, pixel byte counts. */
static uint8_t current_cmd, params[32];
static unsigned param_len, pixel_bytes;
static uint8_t last_pixel[2], first_pixel[2];
static uint8_t caset[4], raset[4];
static unsigned commands_seen;
static bool logging_init = true;
static const char *log_prefix = "INIT";
static int pending_delay = -1;
static bool rst_high_seen;
static unsigned delay_before_first_cmd;

static void flush_command(void)
{
    if (!current_cmd || !logging_init) return;
    printf("%s %02X", log_prefix, current_cmd);
    for (unsigned i = 0; i < param_len; ++i) printf(" %02X", params[i]);
    printf(" DELAY %d\n", pending_delay < 0 ? 0 : pending_delay);
}

void vTaskDelay(unsigned ticks)
{
    delays += ticks;
    if (!commands_seen && rst_high_seen) delay_before_first_cmd += ticks;
    if (commands_seen) pending_delay = (pending_delay < 0 ? 0 : pending_delay) + (int)ticks;
}
esp_err_t gpio_config(const gpio_config_t *c)
{
    for (int p = 0; p < 40; ++p) if (c->pin_bit_mask >> p & 1) configured_output[p] = c->mode == GPIO_MODE_OUTPUT;
    return ESP_OK;
}
esp_err_t gpio_set_level(int pin, int l)
{
    if (pin == SLAB_PIN_LCD_CS && l) cs_ever_high = true;
    if (pin == SLAB_PIN_LCD_RST && l) rst_high_seen = true;
    if (pin == SLAB_PIN_LCD_RST && !l) assert(!commands_seen);   /* reset only before the init */
    assert(pin < 34);   /* never drive an input-only pin */
    level[pin] = l;
    return ESP_OK;
}
esp_err_t spi_bus_initialize(int host, const spi_bus_config_t *b, int dma)
{
    assert(host == SPI2_HOST && dma == SPI_DMA_CH_AUTO);
    assert(b->mosi_io_num == 27 && b->sclk_io_num == 14 && b->miso_io_num == -1);
    assert(b->quadwp_io_num == -1 && b->quadhd_io_num == -1);
    max_transfer = b->max_transfer_sz;
    bus_init = true;
    return ESP_OK;
}
esp_err_t spi_bus_free(int host) { assert(host == SPI2_HOST && !device_added); bus_init = false; return ESP_OK; }
esp_err_t spi_bus_add_device(int host, const spi_device_interface_config_t *d, spi_device_handle_t *out)
{
    assert(host == SPI2_HOST && bus_init);
    spics = d->spics_io_num; clock_hz = d->clock_speed_hz; queue_size = d->queue_size;
    assert(d->flags & SPI_DEVICE_HALFDUPLEX);   /* full duplex fails above 26.7 MHz on GPIO-matrix pins */
    device_added = true;
    *out = (void *)1;
    return ESP_OK;
}
esp_err_t spi_bus_remove_device(spi_device_handle_t d) { (void)d; device_added = false; return ESP_OK; }
void *heap_caps_malloc(size_t size, uint32_t caps)
{
    void *p = malloc(size);
    if (caps & MALLOC_CAP_DMA) { assert(caps & MALLOC_CAP_INTERNAL); dma_bufs[dma_count++] = p; }
    return p;
}
void heap_caps_free(void *p)
{
    for (unsigned i = 0; i < dma_count; ++i) if (dma_bufs[i] == p) dma_bufs[i] = NULL;
    free(p);
}
static bool is_dma(const void *p) { for (unsigned i = 0; i < dma_count; ++i) if (p && dma_bufs[i] == p) return true; return false; }

static void wire(const uint8_t *b, size_t n)
{
    /* Touch rule 1: CS stays low; the screen must already be selected. */
    assert(level[SLAB_PIN_LCD_CS] == 0 && configured_output[SLAB_PIN_LCD_CS]);
    if (level[SLAB_PIN_LCD_DC] == 0) {
        assert(n == 1);
        flush_command();
        current_cmd = b[0]; param_len = 0; pending_delay = -1;
        ++commands_seen;
        return;
    }
    if (current_cmd == 0x2C) {
        assert(n % 2 == 0);
        if (!pixel_bytes) memcpy(first_pixel, b, 2);
        pixel_bytes += (unsigned)n;
        memcpy(last_pixel, b + n - 2, 2);
        return;
    }
    assert(param_len + n <= sizeof(params));
    memcpy(params + param_len, b, n);
    param_len += (unsigned)n;
    if (current_cmd == 0x2A && param_len == 4) memcpy(caset, params, 4);
    if (current_cmd == 0x2B && param_len == 4) memcpy(raset, params, 4);
}
esp_err_t spi_device_polling_transmit(spi_device_handle_t d, spi_transaction_t *t)
{
    (void)d;
    assert(in_flight == 0 && t->length % 8 == 0);
    size_t n = t->length / 8;
    if (t->flags & SPI_TRANS_USE_TXDATA) { assert(n <= 4); wire(t->tx_data, n); }
    else { assert(is_dma(t->tx_buffer) && n <= (size_t)max_transfer); wire(t->tx_buffer, n); }
    return ESP_OK;
}
esp_err_t spi_device_queue_trans(spi_device_handle_t d, spi_transaction_t *t, uint32_t wait)
{
    (void)d; (void)wait;
    assert(level[SLAB_PIN_LCD_DC] == 1 && current_cmd == 0x2C);   /* pixels only, DC held high */
    assert(is_dma(t->tx_buffer) && t->length / 8 <= (size_t)max_transfer && t->length % 16 == 0);
    assert(in_flight < (unsigned)queue_size);
    if (fail_pixels) return ESP_ERR_TIMEOUT;
    /* A buffer may not be refilled while it is still queued. */
    for (unsigned i = q_head; i != q_tail; i = (i + 1) % 4) assert(queue[i]->tx_buffer != t->tx_buffer);
    wire(t->tx_buffer, t->length / 8);
    queue[q_tail] = t; q_tail = (q_tail + 1) % 4;
    if (++in_flight > max_in_flight) max_in_flight = in_flight;
    ++queued_total;
    return ESP_OK;
}
esp_err_t spi_device_get_trans_result(spi_device_handle_t d, spi_transaction_t **t, uint32_t wait)
{
    (void)d; (void)wait;
    assert(in_flight);
    *t = queue[q_head]; q_head = (q_head + 1) % 4;
    --in_flight;
    return ESP_OK;
}

int main(void)
{
    st7365p_config_t cfg;
    st7365p_default_config(&cfg);
    assert(cfg.clock_hz == 40000000 && cfg.madctl == 0x48 && !cfg.col_offset && !cfg.row_offset);
    assert(st7365p_fill(0, 0, 1, 1, 0) == ESP_ERR_INVALID_STATE);
    printf("RESET\n");
    assert(st7365p_init(&cfg) == ESP_OK);
    flush_command();
    logging_init = false;
    printf("RESET_WAIT %u\n", delay_before_first_cmd);
    assert(spics == -1 && clock_hz == 40000000 && queue_size == 2);
    assert(!cs_ever_high && level[SLAB_PIN_LCD_CS] == 0);
    assert(max_transfer == ST7365P_CHUNK_BYTES && dma_count == 2);
    /* Init ends with a black fill of the whole panel through one window. */
    assert(pixel_bytes == 320 * 320 * 2 && last_pixel[0] == 0 && last_pixel[1] == 0);
    assert(!memcmp(caset, (uint8_t[]){0, 0, 1, 63}, 4) && !memcmp(raset, (uint8_t[]){0, 0, 1, 63}, 4));
    assert(max_in_flight == 2 && in_flight == 0);
    unsigned chunks_full = queued_total;
    assert(chunks_full == (320 * 320 * 2 + ST7365P_CHUNK_BYTES - 1) / ST7365P_CHUNK_BYTES);

    /* Blit: big-endian RGB565, stride respected, window bounds. */
    static uint16_t frame[320 * 320];
    for (unsigned i = 0; i < 320 * 320; ++i) frame[i] = (uint16_t)i;
    pixel_bytes = 0;
    uint32_t before = st7365p_bytes_sent();
    assert(st7365p_blit(10, 20, 30, 4, frame + 20 * 320 + 10, 320) == ESP_OK);
    assert(pixel_bytes == 30 * 4 * 2);
    assert(first_pixel[0] == (uint8_t)((20 * 320 + 10) >> 8) && first_pixel[1] == (uint8_t)(20 * 320 + 10));
    uint16_t last = (uint16_t)(23 * 320 + 39);
    assert(last_pixel[0] == (last >> 8) && last_pixel[1] == (uint8_t)last);
    assert(!memcmp(caset, (uint8_t[]){0, 10, 0, 39}, 4) && !memcmp(raset, (uint8_t[]){0, 20, 0, 23}, 4));
    assert(st7365p_bytes_sent() - before == 30 * 4 * 2 + ST7365P_WINDOW_OVERHEAD);
    /* A full-frame blit from a 320-wide frame. */
    pixel_bytes = 0;
    assert(st7365p_blit(0, 0, 320, 320, frame, 320) == ESP_OK && pixel_bytes == 204800);
    assert(last_pixel[0] == (uint8_t)((320 * 320 - 1) >> 8) && last_pixel[1] == (uint8_t)(320 * 320 - 1));
    /* Bounds. */
    assert(st7365p_blit(-1, 0, 1, 1, frame, 320) == ESP_ERR_INVALID_ARG);
    assert(st7365p_blit(319, 0, 2, 1, frame, 320) == ESP_ERR_INVALID_ARG);
    assert(st7365p_blit(0, 319, 1, 2, frame, 320) == ESP_ERR_INVALID_ARG);
    assert(st7365p_blit(0, 0, 10, 1, frame, 5) == ESP_ERR_INVALID_ARG);
    assert(st7365p_blit(0, 0, 1, 1, NULL, 320) == ESP_ERR_INVALID_ARG);
    assert(st7365p_fill(319, 319, 1, 1, 0xF800) == ESP_OK && last_pixel[0] == 0xF8 && last_pixel[1] == 0x00);
    /* A failed pixel transfer leaves nothing queued. */
    fail_pixels = true;
    assert(st7365p_fill(0, 0, 320, 40, 0xFFFF) == ESP_ERR_TIMEOUT && in_flight == 0);
    fail_pixels = false;
    /* Sleep: display off, sleep in, 120 ms. */
    unsigned d0 = delays;
    logging_init = true; current_cmd = 0; log_prefix = "SLEEP";
    assert(st7365p_sleep() == ESP_OK);
    assert(delays - d0 >= 120);
    flush_command();
    logging_init = false;
    st7365p_deinit();
    assert(!bus_init && !device_added && !st7365p_ready());
    assert(!cs_ever_high);
    /* Offsets shift every window. */
    commands_seen = 0; rst_high_seen = false;
    cfg.col_offset = 4; cfg.row_offset = 160;
    assert(st7365p_init(&cfg) == ESP_OK);
    assert(st7365p_fill(0, 0, 2, 2, 0) == ESP_OK);
    assert(!memcmp(caset, (uint8_t[]){0, 4, 0, 5}, 4) && !memcmp(raset, (uint8_t[]){0, 160, 0, 161}, 4));
    st7365p_deinit();
    printf("CHUNKS full_frame=%u chunk_bytes=%u\n", chunks_full, (unsigned)ST7365P_CHUNK_BYTES);
    puts("PASS ST7365P driver: CS never high, no CS pin on the SPI device, DC low only for commands, "
         "DMA ping-pong (2 in flight), big-endian RGB565, bounds, offsets, sleep, bus release");
    return 0;
}
