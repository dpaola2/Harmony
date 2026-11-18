#pragma once
/* Changed-region finder for a full-frame RGB565 buffer. Pure, host-tested.
 * The frame is cut into horizontal bands; each band that differs gets the
 * narrowest column span that covers its changes, and runs of changed bands
 * merge into one window. Each window costs ST7365P_WINDOW_OVERHEAD command
 * bytes and three DC edges, so fewer, larger windows keep LCD_DC (which runs
 * behind the touch wheel) quiet. */
#include <stddef.h>
#include <stdint.h>

typedef struct { uint16_t x, y, w, h; } slab_rect_t;

unsigned slab_dirty_rects(const uint16_t *previous, const uint16_t *current, int width, int height,
                          int band, slab_rect_t *out, unsigned max);
void slab_rect_copy(uint16_t *dst, const uint16_t *src, int width, const slab_rect_t *r);
/* SPI bytes for a set of windows: pixels x 2 plus command overhead. */
size_t slab_rects_bytes(const slab_rect_t *r, unsigned n, unsigned overhead);
