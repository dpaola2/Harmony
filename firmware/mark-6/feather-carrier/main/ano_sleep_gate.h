#pragma once
#include <stdbool.h>
#include <stdint.h>
/* Require a continuously released keypad and cleared interrupt before parking
 * the I2C reader. Unsigned subtraction also works across the millis wrap. */
typedef struct { uint32_t since; bool timing; } ano_sleep_gate_t;
static inline bool ano_sleep_gate_poll(ano_sleep_gate_t *gate, bool requested,
                                       uint32_t buttons, bool irq_high, uint32_t now)
{
    if (!requested || (buttons & 0x3e) != 0x3e || !irq_high) {
        gate->timing=false;
        return false;
    }
    if (!gate->timing) { gate->timing=true; gate->since=now; }
    return now-gate->since>=500;
}
