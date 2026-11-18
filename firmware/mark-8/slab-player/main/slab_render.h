#pragma once
/* 320 x 320 renderer for the slab. Mark-8 copy of
 * firmware/mark-7/pocket-player/main/ui_render.c, laid out for the square
 * screen (six list rows, larger now-playing page), same palette. Pure. */
#include <stdbool.h>
#include <stdint.h>
#include "player_ui.h"

#define SLAB_RENDER_W 320
#define SLAB_RENDER_H 320

typedef struct {
    bool battery_valid;
    unsigned battery_percent;
    bool usb;
} slab_status_t;

void slab_render(uint16_t *frame, const player_ui_view_t *view, unsigned duration, const slab_status_t *status);
bool slab_render_has_long_text(const player_ui_view_t *view);
