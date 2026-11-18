/* Wheel decoder: angle from electrode readings, wraparound, step counting,
 * tap versus scroll, zones, centre tap, holds. A simple finger model gives
 * each ring sector a triangular response around its centre angle. */
#include <assert.h>
#include <math.h>
#include <stdio.h>
#include <string.h>
#include "wheel.h"

static const float centre_deg[9] = {0, 90, 45, 0, -45, -90, -135, 180, 135};
#define AMP 60.0f      /* touch delta through the 1.0 mm disc, counts (bench: about 35 through 1.6 mm) */
#define WIDTH 67.5f    /* response half width, degrees: neighbours overlap like the sawtooth edges */
#define TOUCH 12
#define RELEASE 6

static uint16_t status;   /* MPR121-like touch status with hysteresis */
static void model(float finger_deg, wheel_sample_t *s, uint32_t t)
{
    memset(s, 0, sizeof(*s));
    s->t_ms = t;
    for (int e = 1; e <= 8; ++e) {
        float d = fabsf(wheel_wrap(finger_deg - centre_deg[e]));
        float v = AMP * (1.0f - d / WIDTH);
        s->delta[e] = (int16_t)lroundf(v > 0 ? v : 0);
        if (s->delta[e] > TOUCH) status |= 1u << e;
        else if (s->delta[e] < RELEASE) status &= ~(1u << e);
    }
    s->touched = status;
}
static wheel_sample_t lift(uint32_t t) { status = 0; wheel_sample_t s = {.t_ms = t}; return s; }

static void config(wheel_config_t *c) { wheel_default_config(c); c->min_delta = RELEASE; }

/* Sweep from a to b in `step` degree increments, one read per increment. */
static long sweep(wheel_state_t *w, float a, float b, float step, uint32_t *t, unsigned *reads)
{
    long steps = 0;
    float dir = b > a ? 1.0f : -1.0f;
    for (float f = a;; f += dir * step) {
        if ((dir > 0 && f > b) || (dir < 0 && f < b)) f = b;
        wheel_sample_t s;
        model(f, &s, (*t += 16));
        wheel_events_t ev = wheel_update(w, &s);
        assert(ev.tap == WHEEL_ZONE_NONE);
        steps += ev.steps;
        if (reads) ++*reads;
        if (f == b) break;
    }
    return steps;
}

int main(void)
{
    /* wrap */
    assert(wheel_wrap(190) == -170 && wheel_wrap(-190) == 170 && wheel_wrap(180) == 180 && wheel_wrap(-180) == 180);
    assert(wheel_wrap(720 + 45) == 45);
    /* Angle: one sector alone gives its centre; two equal neighbours give the midpoint, across the wrap too. */
    for (int e = 1; e <= 8; ++e) {
        int16_t d[9] = {0};
        d[e] = 40;
        float a;
        assert(wheel_ring_angle(d, RELEASE, &a) && fabsf(wheel_wrap(a - centre_deg[e])) < 0.01f);
    }
    int16_t d[9] = {0};
    float a;
    d[1] = d[2] = 30; assert(wheel_ring_angle(d, RELEASE, &a) && fabsf(a - 67.5f) < 0.01f);
    memset(d, 0, sizeof(d)); d[8] = d[1] = 30; assert(wheel_ring_angle(d, RELEASE, &a) && fabsf(a - 112.5f) < 0.01f);
    memset(d, 0, sizeof(d)); d[6] = d[7] = 30; assert(wheel_ring_angle(d, RELEASE, &a) && fabsf(wheel_wrap(a + 157.5f)) < 0.01f);
    memset(d, 0, sizeof(d)); d[3] = 5; assert(!wheel_ring_angle(d, RELEASE, &a));
    /* Interpolation is monotonic and close to the finger all the way round. */
    float prev = 0, worst = 0;
    for (int i = 0; i <= 720; ++i) {
        float f = 90.0f - i * 0.5f;
        wheel_sample_t s;
        model(f, &s, 0);
        assert(wheel_ring_angle(s.delta, RELEASE, &a));
        float err = fabsf(wheel_wrap(a - f));
        if (err > worst) worst = err;
        if (i) assert(wheel_wrap(a - prev) <= 0.0001f);   /* clockwise finger, clockwise angle */
        prev = a;
    }
    assert(worst < 8.0f);
    /* Zones (labels at 12, 3, 6 and 9 o'clock), 40 degree half width, dead bands at the diagonals. */
    assert(wheel_zone_at(90, 40) == WHEEL_ZONE_HOME && wheel_zone_at(130, 40) == WHEEL_ZONE_HOME);
    assert(wheel_zone_at(0, 40) == WHEEL_ZONE_NEXT && wheel_zone_at(-90, 40) == WHEEL_ZONE_PLAY);
    assert(wheel_zone_at(180, 40) == WHEEL_ZONE_PREVIOUS && wheel_zone_at(-145, 40) == WHEEL_ZONE_PREVIOUS);
    assert(wheel_zone_at(45, 40) == WHEEL_ZONE_NONE && wheel_zone_at(131, 40) == WHEEL_ZONE_NONE);

    wheel_config_t c;
    config(&c);
    wheel_state_t w;
    uint32_t t = 1000;
    /* One full clockwise turn: first step after 20 degrees, then one per 15: 1 + 340/15 = 23. */
    wheel_init(&w, &c);
    long steps = sweep(&w, 90, 90 - 360, 2, &t, NULL);
    wheel_sample_t up = lift(t += 16);
    wheel_events_t ev = wheel_update(&w, &up);
    assert(steps == 23 && ev.touch_up && ev.tap == WHEEL_ZONE_NONE);
    assert(fabsf(w.net_deg - 360.0f) < 0.5f);
    /* Counter-clockwise is negative. */
    wheel_init(&w, &c);
    assert(sweep(&w, 0, 360, 2, &t, NULL) == -23);
    up = lift(t += 16); wheel_update(&w, &up);
    /* Coarse reads, as TOUCH_IRQ-only reads give, count the same. */
    wheel_init(&w, &c);
    assert(sweep(&w, 90, 90 - 360, 22.5f, &t, NULL) == 23);
    up = lift(t += 16); wheel_update(&w, &up);
    /* Across the +-180 seam (left side). */
    wheel_init(&w, &c);
    assert(sweep(&w, -150, -150 + 60, 3, &t, NULL) == -3);   /* through -120: no seam, sanity */
    up = lift(t += 16); wheel_update(&w, &up);
    wheel_init(&w, &c);
    assert(sweep(&w, 150, 150 + 60, 3, &t, NULL) == -3);     /* 150 to 210 = -150: crosses 180 */
    up = lift(t += 16); wheel_update(&w, &up);
    /* Reverse setting. */
    c.reverse = true;
    wheel_init(&w, &c);
    assert(sweep(&w, 90, 90 - 360, 3, &t, NULL) == -23);
    up = lift(t += 16); wheel_update(&w, &up);
    c.reverse = false;
    /* Glitch: a 150 degree jump between two reads is ignored. */
    wheel_init(&w, &c);
    wheel_sample_t s;
    model(90, &s, t += 16); wheel_update(&w, &s);
    model(-60, &s, t += 16); ev = wheel_update(&w, &s);
    assert(ev.steps == 0);
    up = lift(t += 16); wheel_update(&w, &up);

    /* Taps on each labelled zone: short, nearly still. */
    const struct { float deg; wheel_zone_t zone; } taps[] = {
        {90, WHEEL_ZONE_HOME}, {0, WHEEL_ZONE_NEXT}, {-90, WHEEL_ZONE_PLAY}, {180, WHEEL_ZONE_PREVIOUS},
        {45, WHEEL_ZONE_NONE}, {-135, WHEEL_ZONE_NONE}};
    for (unsigned i = 0; i < sizeof(taps) / sizeof(taps[0]); ++i) {
        wheel_init(&w, &c);
        uint32_t t0 = t += 1000;
        model(taps[i].deg + 3, &s, t0); ev = wheel_update(&w, &s); assert(ev.touch_down);
        model(taps[i].deg - 2, &s, t0 + 60); ev = wheel_update(&w, &s); assert(!ev.steps);
        model(taps[i].deg, &s, t0 + 120); wheel_update(&w, &s);
        up = lift(t0 + 180); ev = wheel_update(&w, &up);
        assert(ev.touch_up && ev.tap == taps[i].zone && !ev.steps);
    }
    /* Centre tap: the centre pad dominates, the inner ring edges see a little. */
    wheel_init(&w, &c);
    t += 1000;
    wheel_sample_t centre = {.touched = 1, .t_ms = t};
    centre.delta[0] = 55; centre.delta[1] = 9; centre.delta[5] = 7;
    ev = wheel_update(&w, &centre); assert(ev.touch_down);
    centre.t_ms = t + 100; wheel_update(&w, &centre);
    up = lift(t + 200); ev = wheel_update(&w, &up);
    assert(ev.tap == WHEEL_ZONE_CENTRE);
    /* Too long for a tap, too short for a hold: nothing. */
    wheel_init(&w, &c);
    t += 1000;
    model(90, &s, t); wheel_update(&w, &s);
    assert(wheel_tick(&w, t + 500).hold == WHEEL_ZONE_NONE);
    up = lift(t + 500); ev = wheel_update(&w, &up);
    assert(ev.tap == WHEEL_ZONE_NONE && ev.hold == WHEEL_ZONE_NONE);
    /* Hold from the clock alone (no reads between), fires once, then no tap on release. */
    wheel_init(&w, &c);
    t += 1000;
    model(90, &s, t); wheel_update(&w, &s);
    assert(wheel_tick(&w, t + 699).hold == WHEEL_ZONE_NONE);
    assert(wheel_tick(&w, t + 700).hold == WHEEL_ZONE_HOME);
    assert(wheel_tick(&w, t + 800).hold == WHEEL_ZONE_NONE);
    up = lift(t + 900); ev = wheel_update(&w, &up);
    assert(ev.tap == WHEEL_ZONE_NONE);
    /* Centre hold. */
    wheel_init(&w, &c);
    t += 1000;
    centre.t_ms = t; wheel_update(&w, &centre);
    assert(wheel_tick(&w, t + 750).hold == WHEEL_ZONE_CENTRE);
    up = lift(t + 800); wheel_update(&w, &up);
    /* A scroll is never a tap; movement past the tap limit but before the first step is neither. */
    wheel_init(&w, &c);
    t += 1000;
    model(90, &s, t); wheel_update(&w, &s);
    model(60, &s, t + 50); ev = wheel_update(&w, &s); assert(ev.steps == 1);
    up = lift(t + 100); ev = wheel_update(&w, &up); assert(ev.tap == WHEEL_ZONE_NONE);
    wheel_init(&w, &c);
    t += 1000;
    model(0, &s, t); wheel_update(&w, &s);
    model(-15, &s, t + 50); ev = wheel_update(&w, &s); assert(ev.steps == 0);
    up = lift(t + 100); ev = wheel_update(&w, &up); assert(ev.tap == WHEEL_ZONE_NONE);
    /* A moving touch cannot become a hold. */
    wheel_init(&w, &c);
    t += 1000;
    model(90, &s, t); wheel_update(&w, &s);
    model(50, &s, t + 100); wheel_update(&w, &s);
    assert(wheel_tick(&w, t + 2000).hold == WHEEL_ZONE_NONE);
    up = lift(t + 2100); wheel_update(&w, &up);

    /* How many touch status changes (TOUCH_IRQ edges) one slow turn makes in this model. */
    status = 0;
    uint16_t last = 0;
    unsigned changes = 0;
    for (int i = 0; i <= 3600; ++i) {
        model(90.0f - i * 0.1f, &s, 0);
        if (i && s.touched != last) ++changes;
        last = s.touched;
    }
    printf("WHEEL model: %u touch status changes per turn (position updates with TOUCH_IRQ-only reads); "
           "angle error at most %.1f degrees\n", changes, worst);
    puts("PASS wheel decoder: angles, wraparound, 23 steps per turn either way, coarse reads, seam, reverse, "
         "glitch, taps on 4 zones and dead bands, centre tap, holds, tap versus scroll");
    return 0;
}
