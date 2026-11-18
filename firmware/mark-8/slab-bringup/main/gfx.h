#pragma once
/* Tiny RGB565 drawing on a 320 x 320 frame. Pure, host-tested (previews). */
#include <stdint.h>

#define GFX_W 320
#define GFX_H 320
#define GFX_RGB(r, g, b) ((uint16_t)((((r) >> 3) << 11) | (((g) >> 2) << 5) | ((b) >> 3)))
#define GFX_BLACK 0x0000
#define GFX_WHITE 0xFFFF
#define GFX_RED   0xF800
#define GFX_GREEN 0x07E0
#define GFX_BLUE  0x001F
#define GFX_GREY  GFX_RGB(110, 110, 110)
#define GFX_AMBER GFX_RGB(255, 176, 0)

void gfx_fill(uint16_t *fb, int x, int y, int w, int h, uint16_t c);
/* 8 x 16 font (Mark-6 font8x16), scaled. Returns the x after the text. */
int gfx_text(uint16_t *fb, int x, int y, const char *s, uint16_t fg, uint16_t bg, int scale);
/* Filled triangle. */
void gfx_triangle(uint16_t *fb, int x0, int y0, int x1, int y1, int x2, int y2, uint16_t c);
/* Ring of radius r and thickness t. */
void gfx_ring(uint16_t *fb, int cx, int cy, int r, int t, uint16_t c);
void gfx_disc(uint16_t *fb, int cx, int cy, int r, uint16_t c);
