/* Touch-noise statistics. Pure, host-tested. */
#include <string.h>
#include "noise_stats.h"

void noise_reset(noise_acc_t *a)
{
    for (unsigned i = 0; i < NOISE_ELECTRODES; ++i) { a->min[i] = 0xFFFF; a->max[i] = 0; }
    a->n = 0;
}

void noise_add(noise_acc_t *a, const uint16_t filtered[NOISE_ELECTRODES])
{
    for (unsigned i = 0; i < NOISE_ELECTRODES; ++i) {
        if (filtered[i] < a->min[i]) a->min[i] = filtered[i];
        if (filtered[i] > a->max[i]) a->max[i] = filtered[i];
    }
    ++a->n;
}

void noise_finish(const noise_acc_t *a, noise_case_t *c)
{
    c->worst = 0;
    c->samples = (uint16_t)a->n;
    for (unsigned i = 0; i < NOISE_ELECTRODES; ++i) {
        unsigned pp = a->n ? (unsigned)(a->max[i] - a->min[i]) : 0;
        c->pp[i] = (uint8_t)(pp > 255 ? 255 : pp);
        if (c->pp[i] > c->worst) c->worst = c->pp[i];
    }
}

int noise_quietest(const noise_case_t *cases, unsigned n)
{
    int best = -1;
    unsigned best_sum = 0;
    for (unsigned i = 0; i < n; ++i) {
        const noise_case_t *c = &cases[i];
        if (!c->pwm_case || c->skipped || !c->samples) continue;
        unsigned sum = 0;
        for (unsigned e = 0; e < NOISE_ELECTRODES; ++e) sum += c->pp[e];
        if (best < 0) { best = (int)i; best_sum = sum; continue; }
        const noise_case_t *b = &cases[best];
        bool better = c->worst < b->worst ||
            (c->worst == b->worst && (sum < best_sum || (sum == best_sum && c->pwm_hz > b->pwm_hz)));
        if (better) { best = (int)i; best_sum = sum; }
    }
    return best;
}

bool noise_thresholds(const noise_case_t *cases, unsigned n, int chosen,
                      uint8_t touch[NOISE_ELECTRODES], uint8_t release[NOISE_ELECTRODES],
                      uint8_t worst[NOISE_ELECTRODES])
{
    bool ok = true;
    memset(worst, 0, NOISE_ELECTRODES);
    for (unsigned i = 0; i < n; ++i) {
        const noise_case_t *c = &cases[i];
        if (c->skipped || !c->samples || !((int)i == chosen || c->activity)) continue;
        for (unsigned e = 0; e < NOISE_ELECTRODES; ++e) if (c->pp[e] > worst[e]) worst[e] = c->pp[e];
    }
    for (unsigned e = 0; e < NOISE_ELECTRODES; ++e) {
        unsigned t = (unsigned)worst[e] * NOISE_THRESHOLD_FACTOR;
        if (t < NOISE_MIN_TOUCH) t = NOISE_MIN_TOUCH;
        if (t > 254) t = 254;
        if (t > NOISE_PASS_MAX_TOUCH) ok = false;
        touch[e] = (uint8_t)t;
        release[e] = (uint8_t)(t / 2);
    }
    return ok;
}
