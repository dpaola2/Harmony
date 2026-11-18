#pragma once
/* Touch-wheel decoder. Pure C, host-tested.
 *
 * Angles are device math angles seen from the front: 0 = +X (right, 3
 * o'clock), 90 = +Y (top, toward the screen), counter-clockwise positive.
 * ELE1 to ELE8 sit at 90, 45, 0, -45, -90, -135, 180, 135 degrees
 * (design.py SECTOR_ANGLES); ELE0 is the centre pad. Scroll steps count
 * clockwise as positive (down a list, volume up).
 *
 * The printed wheel disc labels (enclosure README item 2, label circle r 12.2):
 * HOME at the top, previous at the left, next at the right, play/pause at the
 * bottom. */
#include <stdbool.h>
#include <stdint.h>

#define WHEEL_ELECTRODES 9

typedef enum {
    WHEEL_ZONE_NONE = -1,
    WHEEL_ZONE_CENTRE = 0,
    WHEEL_ZONE_HOME,      /* top, +Y */
    WHEEL_ZONE_NEXT,      /* right, +X */
    WHEEL_ZONE_PLAY,      /* bottom, -Y */
    WHEEL_ZONE_PREVIOUS,  /* left, -X */
} wheel_zone_t;

typedef struct {
    float step_deg;        /* angle per scroll step */
    float start_deg;       /* movement before the first step of a touch */
    uint32_t tap_max_ms;   /* longest tap */
    float tap_max_deg;     /* most movement in a tap */
    uint32_t hold_ms;      /* still touch longer than this is a hold */
    float zone_half_deg;   /* tap zone half width about each label */
    int16_t min_delta;     /* weakest ring signal used for an angle */
    bool reverse;          /* flip the scroll direction */
} wheel_config_t;

typedef struct {
    uint16_t touched;                  /* MPR121 status bits, ELE0 = bit 0 */
    int16_t delta[WHEEL_ELECTRODES];   /* baseline - filtered */
    uint32_t t_ms;
} wheel_sample_t;

typedef struct {
    int steps;            /* scroll steps this update, clockwise positive */
    wheel_zone_t tap;     /* zone tapped (on release), or NONE */
    wheel_zone_t hold;    /* zone held (fires once while touching), or NONE */
    bool touch_down, touch_up;
} wheel_events_t;

typedef struct {
    wheel_config_t cfg;
    bool active, have_angle, scrolling, held;
    uint32_t down_ms, last_ms;
    float last_deg;        /* last ring angle */
    float acc_deg;         /* clockwise movement not yet turned into steps */
    float travel_deg;      /* largest distance from the touch-down angle */
    float net_deg;         /* clockwise movement since touch-down */
    float best_deg;        /* angle at the strongest ring sample */
    int16_t best_ring, best_centre;
    unsigned samples, ring_samples, centre_samples;
    /* Running totals for the bring-up test. */
    long total_steps;
    float turn_deg;        /* clockwise movement in the current touch, signed */
} wheel_state_t;

void wheel_default_config(wheel_config_t *cfg);
void wheel_init(wheel_state_t *s, const wheel_config_t *cfg);

/* Ring angle from the strongest sector and its two neighbours (vector sum).
 * false when no ring sector reaches min_delta. */
bool wheel_ring_angle(const int16_t delta[WHEEL_ELECTRODES], int16_t min_delta, float *deg);
/* Labelled zone that holds an angle, or NONE in the gaps between zones. */
wheel_zone_t wheel_zone_at(float deg, float half_width);
/* Wrap an angle difference into (-180, 180]. */
float wheel_wrap(float deg);
const char *wheel_zone_name(wheel_zone_t z);

/* Feed every MPR121 read. */
wheel_events_t wheel_update(wheel_state_t *s, const wheel_sample_t *in);
/* Call between reads (no I2C): detects holds from the clock alone. */
wheel_events_t wheel_tick(wheel_state_t *s, uint32_t now_ms);
