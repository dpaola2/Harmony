#pragma once
/* Mark-8 replacement for firmware/mark-7/pocket-player/main/player_power.h:
 * battery percent from the MAX17048, VSYS-compensated backlight, deep sleep
 * with side-button and touch wake. */
#include <stdbool.h>
#include <stdint.h>

typedef struct {
    bool valid;          /* a gauge reading has arrived */
    unsigned percent;    /* MAX17048 state of charge */
    unsigned vcell_mv;
    bool usb;            /* VBUS present */
    unsigned vsys_mv;    /* estimate used for the backlight */
    unsigned bl_permille;
} player_power_status_t;

void player_power_init(uint32_t backlight_hz);
/* Display task, about once a second: ADC, backlight duty, queued gauge read. */
void player_power_poll(void);
player_power_status_t player_power_status(void);
void player_power_backlight(bool on);
/* Display task owns this synchronous transition and all LCD access. Returns
 * only if the player cannot sleep (a notice explains why). */
void player_power_sleep(void);
