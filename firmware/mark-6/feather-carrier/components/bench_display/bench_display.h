#pragma once
#include <stdint.h>
#include "esp_err.h"

/* Single drawing task owns this driver. Coordinates use 320 x 480 portrait. */
esp_err_t bench_display_init(void);
esp_err_t bench_display_fill(int x, int y, int w, int h, uint16_t color);
esp_err_t bench_display_text(int x, int y, const char *text, uint16_t fg, uint16_t bg);
esp_err_t bench_display_probe(void);
esp_err_t bench_display_white_isolation(void);
