#pragma once
#include <stdbool.h>
#include <stdint.h>
typedef struct { bool primed, touching; uint8_t buttons, position; int residual; } wheel_state_t;
typedef struct { int steps; uint8_t pressed, released; } wheel_event_t;
/* Wire order: 35, button bits, 0..BE even touch coordinate, 00/80 touch flag. */
bool wheel_decode(wheel_state_t *state, const uint8_t packet[4], wheel_event_t *event);
