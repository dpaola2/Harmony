/* Tiny RGB565 drawing. Font: Mark-6 font8x16 (see its LICENSE-st7789). */
#include <stddef.h>
#include "gfx.h"
#include "font8x16.h"

void gfx_fill(uint16_t *fb, int x, int y, int w, int h, uint16_t c)
{
    int x1 = x + w, y1 = y + h;
    if (x < 0) x = 0;
    if (y < 0) y = 0;
    if (x1 > GFX_W) x1 = GFX_W;
    if (y1 > GFX_H) y1 = GFX_H;
    for (int j = y; j < y1; ++j)
        for (int i = x; i < x1; ++i) fb[(size_t)j * GFX_W + i] = c;
}

int gfx_text(uint16_t *fb, int x, int y, const char *s, uint16_t fg, uint16_t bg, int scale)
{
    for (; *s; ++s) {
        unsigned ch = (unsigned char)*s;
        if (ch < 32 || ch > 126) ch = '?';
        if (x + 8 * scale > GFX_W) break;
        for (int row = 0; row < 16; ++row) {
            unsigned bits = font8x16[(ch - 32) * 16 + row];
            for (int col = 0; col < 8; ++col)
                gfx_fill(fb, x + col * scale, y + row * scale, scale, scale, (bits & (0x80u >> col)) ? fg : bg);
        }
        x += 8 * scale;
    }
    return x;
}

static int edge(int ax, int ay, int bx, int by, int px, int py)
{
    return (bx - ax) * (py - ay) - (by - ay) * (px - ax);
}

void gfx_triangle(uint16_t *fb, int x0, int y0, int x1, int y1, int x2, int y2, uint16_t c)
{
    int minx = x0 < x1 ? (x0 < x2 ? x0 : x2) : (x1 < x2 ? x1 : x2);
    int maxx = x0 > x1 ? (x0 > x2 ? x0 : x2) : (x1 > x2 ? x1 : x2);
    int miny = y0 < y1 ? (y0 < y2 ? y0 : y2) : (y1 < y2 ? y1 : y2);
    int maxy = y0 > y1 ? (y0 > y2 ? y0 : y2) : (y1 > y2 ? y1 : y2);
    int area = edge(x0, y0, x1, y1, x2, y2);
    if (!area) return;
    for (int y = miny; y <= maxy; ++y)
        for (int x = minx; x <= maxx; ++x) {
            if (x < 0 || y < 0 || x >= GFX_W || y >= GFX_H) continue;
            int a = edge(x1, y1, x2, y2, x, y), b = edge(x2, y2, x0, y0, x, y), d = edge(x0, y0, x1, y1, x, y);
            if (area > 0 ? (a >= 0 && b >= 0 && d >= 0) : (a <= 0 && b <= 0 && d <= 0))
                fb[(size_t)y * GFX_W + x] = c;
        }
}

void gfx_ring(uint16_t *fb, int cx, int cy, int r, int t, uint16_t c)
{
    int ro = r * r, ri = (r - t) * (r - t);
    for (int y = cy - r; y <= cy + r; ++y)
        for (int x = cx - r; x <= cx + r; ++x) {
            int d = (x - cx) * (x - cx) + (y - cy) * (y - cy);
            if (d <= ro && d >= ri && x >= 0 && y >= 0 && x < GFX_W && y < GFX_H) fb[(size_t)y * GFX_W + x] = c;
        }
}

void gfx_disc(uint16_t *fb, int cx, int cy, int r, uint16_t c) { gfx_ring(fb, cx, cy, r, r, c); }
