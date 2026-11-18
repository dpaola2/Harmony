/* Changed-region finder. Pure, host-tested. */
#include <string.h>
#include "slab_dirty.h"

static void band_span(const uint16_t *a, const uint16_t *b, int width, int y0, int rows, int *x0, int *x1)
{
    *x0 = width; *x1 = -1;
    for (int y = y0; y < y0 + rows; ++y) {
        const uint16_t *pa = a + (size_t)y * width, *pb = b + (size_t)y * width;
        if (!memcmp(pa, pb, (size_t)width * sizeof(*pa))) continue;
        int l = 0, r = width - 1;
        while (pa[l] == pb[l]) ++l;
        while (pa[r] == pb[r]) --r;
        if (l < *x0) *x0 = l;
        if (r > *x1) *x1 = r;
    }
}

unsigned slab_dirty_rects(const uint16_t *previous, const uint16_t *current, int width, int height,
                          int band, slab_rect_t *out, unsigned max)
{
    unsigned n = 0;
    int run_y = -1, run_x0 = 0, run_x1 = 0;
    int bands = (height + band - 1) / band;
    for (int b = 0; b <= bands; ++b) {
        int y = b < bands ? b * band : height;   /* one pass past the end closes the last run */
        int rows = y + band > height ? height - y : band;
        int x0 = width, x1 = -1;
        if (b < bands) band_span(previous, current, width, y, rows, &x0, &x1);
        if (x1 >= 0) {
            if (run_y < 0) { run_y = y; run_x0 = x0; run_x1 = x1; }
            else { if (x0 < run_x0) run_x0 = x0; if (x1 > run_x1) run_x1 = x1; }
            continue;
        }
        if (run_y < 0) continue;
        slab_rect_t r = {(uint16_t)run_x0, (uint16_t)run_y, (uint16_t)(run_x1 - run_x0 + 1), (uint16_t)(y - run_y)};
        if (n < max) out[n++] = r;
        else {
            /* Out of slots: grow the last window to cover this one. */
            slab_rect_t *l = &out[max - 1];
            int lx0 = l->x < r.x ? l->x : r.x;
            int lx1 = l->x + l->w > r.x + r.w ? l->x + l->w : r.x + r.w;
            l->x = (uint16_t)lx0; l->w = (uint16_t)(lx1 - lx0); l->h = (uint16_t)(r.y + r.h - l->y);
        }
        run_y = -1;
    }
    return n;
}

void slab_rect_copy(uint16_t *dst, const uint16_t *src, int width, const slab_rect_t *r)
{
    for (int y = r->y; y < r->y + r->h; ++y)
        memcpy(dst + (size_t)y * width + r->x, src + (size_t)y * width + r->x, (size_t)r->w * sizeof(*dst));
}

size_t slab_rects_bytes(const slab_rect_t *r, unsigned n, unsigned overhead)
{
    size_t bytes = 0;
    for (unsigned i = 0; i < n; ++i) bytes += (size_t)r[i].w * r[i].h * 2 + overhead;
    return bytes;
}
