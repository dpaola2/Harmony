#pragma once
#include <stdint.h>
#include <stdbool.h>
#include "esp_err.h"

/* Single drawing task owns this driver. Coordinates use 320 x 480 portrait. */
esp_err_t bench_display_init(void);
/* Caller owns initialized SPI2 bus; only one task calls display functions. */
esp_err_t bench_display_init_on_existing_bus(void);
esp_err_t bench_display_fill(int x, int y, int w, int h, uint16_t color);
/* At most eight rows per call, native RGB565 words; bus released after strip. */
esp_err_t bench_display_blit(int x, int y, int w, int h, const uint16_t *data);
esp_err_t bench_display_text(int x, int y, const char *text, uint16_t fg, uint16_t bg);
esp_err_t bench_display_probe(void);
esp_err_t bench_display_white_isolation(void);

/* Fallback when a missing SD card left SPI uninitialized. */
esp_err_t bench_display_init_without_storage(void);
esp_err_t bench_display_backlight(bool on);
