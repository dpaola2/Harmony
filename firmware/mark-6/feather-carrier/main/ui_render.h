#pragma once
#include <stdint.h>
#include "player_ui.h"
/* Pure RGB565 renderer. Caller supplies 320*480 words. */
void ui_render(uint16_t *frame, const player_ui_view_t *view, unsigned duration);
/* Fast list selection path; false requires a complete render. */
bool ui_render_selection(uint16_t *frame, const player_ui_view_t *view,
                         const player_ui_view_t *previous);
