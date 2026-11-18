/* Wheel and side-button event mapping. Pure, host-tested. */
#include "controls_map.h"

static unsigned put(controls_action_t *out, unsigned n, unsigned max, player_ui_input_t in, int delta)
{
    if (n < max) out[n] = (controls_action_t){in, delta};
    return n + 1;
}

unsigned controls_map_wheel(const wheel_events_t *ev, controls_action_t *out, unsigned max)
{
    unsigned n = 0;
    if (ev->steps) n = put(out, n, max, PLAYER_UI_SCROLL, ev->steps);
    switch (ev->tap) {
    case WHEEL_ZONE_CENTRE: n = put(out, n, max, PLAYER_UI_SELECT, 0); break;
    case WHEEL_ZONE_HOME: n = put(out, n, max, PLAYER_UI_BACK, 0); break;
    case WHEEL_ZONE_NEXT: n = put(out, n, max, PLAYER_UI_NEXT, 0); break;
    case WHEEL_ZONE_PREVIOUS: n = put(out, n, max, PLAYER_UI_PREVIOUS, 0); break;
    case WHEEL_ZONE_PLAY: n = put(out, n, max, PLAYER_UI_PLAY_PAUSE, 0); break;
    default: break;
    }
    if (ev->hold == WHEEL_ZONE_HOME)
        for (unsigned i = 0; i < CONTROLS_ROOT_BACKS; ++i) n = put(out, n, max, PLAYER_UI_BACK, 0);
    return n < max ? n : max;
}

bool controls_map_side_short(unsigned press_ms, unsigned long_ms, controls_action_t *out)
{
    if (press_ms < 30 || press_ms >= long_ms) return false;
    *out = (controls_action_t){PLAYER_UI_PLAY_PAUSE, 0};
    return true;
}
