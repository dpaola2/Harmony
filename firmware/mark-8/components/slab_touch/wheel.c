/* Touch-wheel decoder. Pure C, host-tested. See wheel.h for conventions. */
#include <math.h>
#include <string.h>
#include "wheel.h"

#define PI_F 3.14159265f
#define JUMP_LIMIT_DEG 100.0f   /* larger moves between two reads are glitches */

/* Sector centre angles, index = electrode (ELE0 is the centre pad). */
static const float sector_deg[WHEEL_ELECTRODES] = {0, 90, 45, 0, -45, -90, -135, 180, 135};

void wheel_default_config(wheel_config_t *c)
{
    *c = (wheel_config_t){.step_deg = 15, .start_deg = 20, .tap_max_ms = 400, .tap_max_deg = 12,
        .hold_ms = 700, .zone_half_deg = 40, .min_delta = 4, .reverse = false};
}

void wheel_init(wheel_state_t *s, const wheel_config_t *cfg)
{
    memset(s, 0, sizeof(*s));
    s->cfg = *cfg;
}

float wheel_wrap(float deg)
{
    deg = fmodf(deg, 360.0f);
    if (deg > 180.0f) deg -= 360.0f;
    if (deg <= -180.0f) deg += 360.0f;
    return deg;
}

bool wheel_ring_angle(const int16_t delta[WHEEL_ELECTRODES], int16_t min_delta, float *deg)
{
    int k = 1;
    for (int i = 2; i <= 8; ++i) if (delta[i] > delta[k]) k = i;
    if (delta[k] < min_delta) return false;
    int neighbours[3] = {k == 1 ? 8 : k - 1, k, k == 8 ? 1 : k + 1};
    float x = 0, y = 0;
    for (int j = 0; j < 3; ++j) {
        int e = neighbours[j];
        float w = delta[e] > 0 ? (float)delta[e] : 0.0f;
        x += w * cosf(sector_deg[e] * PI_F / 180.0f);
        y += w * sinf(sector_deg[e] * PI_F / 180.0f);
    }
    *deg = atan2f(y, x) * 180.0f / PI_F;
    return true;
}

wheel_zone_t wheel_zone_at(float deg, float half)
{
    static const struct { float centre; wheel_zone_t zone; } zones[] = {
        {90, WHEEL_ZONE_HOME}, {0, WHEEL_ZONE_NEXT}, {-90, WHEEL_ZONE_PLAY}, {180, WHEEL_ZONE_PREVIOUS}};
    for (unsigned i = 0; i < 4; ++i)
        if (fabsf(wheel_wrap(deg - zones[i].centre)) <= half) return zones[i].zone;
    return WHEEL_ZONE_NONE;
}

const char *wheel_zone_name(wheel_zone_t z)
{
    switch (z) {
    case WHEEL_ZONE_CENTRE: return "CENTRE";
    case WHEEL_ZONE_HOME: return "HOME";
    case WHEEL_ZONE_NEXT: return "NEXT";
    case WHEEL_ZONE_PLAY: return "PLAY";
    case WHEEL_ZONE_PREVIOUS: return "PREVIOUS";
    default: return "NONE";
    }
}

static wheel_zone_t touch_zone(const wheel_state_t *s)
{
    if (s->centre_samples && (s->centre_samples >= s->ring_samples || s->best_centre >= s->best_ring))
        return WHEEL_ZONE_CENTRE;
    if (s->ring_samples) return wheel_zone_at(s->best_deg, s->cfg.zone_half_deg);
    return WHEEL_ZONE_NONE;
}

static void check_hold(wheel_state_t *s, uint32_t now, wheel_events_t *ev)
{
    if (s->active && !s->scrolling && !s->held && now - s->down_ms >= s->cfg.hold_ms &&
        s->travel_deg <= s->cfg.tap_max_deg) {
        s->held = true;
        ev->hold = touch_zone(s);
    }
}

wheel_events_t wheel_update(wheel_state_t *s, const wheel_sample_t *in)
{
    wheel_events_t ev = {.steps = 0, .tap = WHEEL_ZONE_NONE, .hold = WHEEL_ZONE_NONE};
    bool any = (in->touched & 0x1FF) != 0;
    if (!s->active) {
        if (!any) return ev;
        s->active = true; s->have_angle = s->scrolling = s->held = false;
        s->down_ms = in->t_ms;
        s->acc_deg = s->travel_deg = s->net_deg = 0;
        s->best_ring = s->best_centre = 0;
        s->samples = s->ring_samples = s->centre_samples = 0;
        ev.touch_down = true;
    }
    s->last_ms = in->t_ms;
    if (!any) {
        s->active = false;
        ev.touch_up = true;
        if (!s->scrolling && !s->held && in->t_ms - s->down_ms <= s->cfg.tap_max_ms &&
            s->travel_deg <= s->cfg.tap_max_deg)
            ev.tap = touch_zone(s);
        return ev;
    }
    ++s->samples;
    int16_t ring_max = 0;
    for (int i = 1; i <= 8; ++i) if (in->delta[i] > ring_max) ring_max = in->delta[i];
    float a;
    bool ring = wheel_ring_angle(in->delta, s->cfg.min_delta, &a);
    bool centre = (in->touched & 1) && in->delta[0] >= ring_max;
    if (centre) {
        ++s->centre_samples;
        if (in->delta[0] > s->best_centre) s->best_centre = in->delta[0];
    } else if (ring) {
        ++s->ring_samples;
        if (ring_max > s->best_ring) { s->best_ring = ring_max; s->best_deg = a; }
        if (!s->have_angle) {
            s->have_angle = true;
        } else {
            float d = wheel_wrap(a - s->last_deg);
            if (fabsf(d) <= JUMP_LIMIT_DEG) {
                float cw = s->cfg.reverse ? d : -d;
                s->acc_deg += cw;
                s->net_deg += cw;
                if (fabsf(s->net_deg) > s->travel_deg) s->travel_deg = fabsf(s->net_deg);
                if (!s->scrolling && fabsf(s->acc_deg) >= s->cfg.start_deg) {
                    int dir = s->acc_deg > 0 ? 1 : -1;
                    s->scrolling = true;
                    ev.steps += dir;
                    s->acc_deg -= dir * s->cfg.start_deg;
                }
                if (s->scrolling) {
                    while (s->acc_deg >= s->cfg.step_deg) { ++ev.steps; s->acc_deg -= s->cfg.step_deg; }
                    while (s->acc_deg <= -s->cfg.step_deg) { --ev.steps; s->acc_deg += s->cfg.step_deg; }
                }
            }
        }
        s->last_deg = a;
    }
    s->total_steps += ev.steps;
    check_hold(s, in->t_ms, &ev);
    return ev;
}

wheel_events_t wheel_tick(wheel_state_t *s, uint32_t now_ms)
{
    wheel_events_t ev = {.steps = 0, .tap = WHEEL_ZONE_NONE, .hold = WHEEL_ZONE_NONE};
    check_hold(s, now_ms, &ev);
    return ev;
}
