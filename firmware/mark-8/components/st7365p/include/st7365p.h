#pragma once
/* ST7365P on HSPI (SPI2): SCK 14, MOSI 27, DC 33, RST 32, CS 26 held low.
 *
 * Touch rule 1: the screen is the only device on its bus, so the device has
 * no chip select (spics_io_num = -1) and GPIO26 is driven low once after the
 * screen has power. Pixels go out by DMA from two internal buffers in turn;
 * the source may be in PSRAM. One task owns the driver. */
#include <stdbool.h>
#include <stdint.h>
#include "esp_err.h"

#define ST7365P_WIDTH  320
#define ST7365P_HEIGHT 320
#define ST7365P_CHUNK_BYTES (ST7365P_WIDTH * 10 * 2)   /* one DMA transfer: 10 rows */
#define ST7365P_WINDOW_OVERHEAD 11                      /* CASET 1+4, RASET 1+4, RAMWR 1 */

typedef struct {
    uint32_t clock_hz;
    uint8_t madctl;
    uint16_t col_offset, row_offset;
} st7365p_config_t;

void st7365p_default_config(st7365p_config_t *cfg);
/* 3V3_PERIPH must be on. Sets up the bus, resets and initializes the panel,
 * fills it black. */
esp_err_t st7365p_init(const st7365p_config_t *cfg);
bool st7365p_ready(void);
esp_err_t st7365p_fill(int x, int y, int w, int h, uint16_t color);
/* Native RGB565 words; stride in pixels. */
esp_err_t st7365p_blit(int x, int y, int w, int h, const uint16_t *src, int stride);
/* Display off and sleep in (before 3V3_PERIPH goes off). */
esp_err_t st7365p_sleep(void);
/* Releases the bus and the DMA buffers. */
void st7365p_deinit(void);
/* Bytes clocked out since init (commands and pixels). */
uint32_t st7365p_bytes_sent(void);
