#include "input_filter.h"
input_events_t input_filter_poll(input_filter_t *f, uint32_t position, uint32_t pins,
                                 uint32_t now, unsigned rotation)
{
    input_events_t e = {0};
    uint8_t down = (uint8_t)(~pins >> 1) & 31;
    if (!f->initialized) {
        f->initialized = true;
        f->position = position;
        f->stable = f->candidate = down;
        return e;
    }
    uint32_t distance = position - f->position;
    if (distance <= 16) e.steps = (int)distance;
    else if (distance >= UINT32_MAX - 15) e.steps = -(int)(0U - distance);
    /* A large jump is a reset/glitch, not a request to traverse the album. */
    f->position = position;
    static const unsigned raw_to_logical[] = {INPUT_SELECT, INPUT_UP, INPUT_LEFT, INPUT_DOWN, INPUT_RIGHT};
    for (unsigned i = 0; i < 5; ++i) {
        unsigned bit = 1U << i;
        if ((f->candidate ^ down) & bit) {
            f->candidate ^= bit;
            f->changed[i] = now;
        }
        if (((f->stable ^ f->candidate) & bit) && (uint32_t)(now - f->changed[i]) >= 40) {
            f->stable ^= bit;
            if (f->stable & bit) {
                unsigned logical = raw_to_logical[i];
                if (logical) logical = 1 + (logical - 1 + rotation) % 4;
                e.pressed |= 1U << logical;
            }
        }
    }
    return e;
}
