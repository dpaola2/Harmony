#pragma once
#include <stdbool.h>
#include <stdint.h>
typedef enum { INPUT_SELECT, INPUT_UP, INPUT_RIGHT, INPUT_DOWN, INPUT_LEFT } input_button_t;
typedef struct {
    bool initialized;
    uint32_t position, changed[5];
    uint8_t stable, candidate;
} input_filter_t;
typedef struct { int steps; uint8_t pressed; } input_events_t;
/* Pin bits 1..5, active low. Startup-held keys do not fire. */
input_events_t input_filter_poll(input_filter_t *f, uint32_t position, uint32_t pins,
                                 uint32_t now_ms, unsigned clockwise_quarters);
