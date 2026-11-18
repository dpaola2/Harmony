#pragma once
/* Wheel and side-button events to the Mark-7 player input events.
 * Pure, host-tested.
 *
 *   ring movement           SCROLL, one per step, clockwise positive
 *   tap centre pad          SELECT
 *   tap HOME (top)          BACK      (Mark-7 "Menu goes back")
 *   hold HOME               BACK to the root page (repeated BACK)
 *   tap next (right)        NEXT
 *   tap previous (left)     PREVIOUS
 *   tap play/pause (bottom) PLAY_PAUSE
 *   side button short       PLAY_PAUSE
 *   side button long        deep sleep (not a UI event) */
#include <stdbool.h>
#include "player_ui.h"
#include "wheel.h"

#define CONTROLS_MAX_ACTIONS 10
#define CONTROLS_ROOT_BACKS 7   /* player_ui.c stack depth 8: seven BACKs always reach the root */

typedef struct { player_ui_input_t input; int delta; } controls_action_t;

unsigned controls_map_wheel(const wheel_events_t *ev, controls_action_t *out, unsigned max);
/* Side button released after press_ms. true: a UI event in *out. */
bool controls_map_side_short(unsigned press_ms, unsigned long_ms, controls_action_t *out);
