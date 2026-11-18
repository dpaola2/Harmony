#pragma once
/* MLT-5020 magnetic buzzer (4 kHz) from VSYS through 33 ohm, switched by Q6
 * on GPIO2. The gate line (BZ_GATE) runs behind the touch wheel; the player
 * starts its clicks right after an MPR121 read, so a click of a few ms ends
 * before the next touch measurement. */
#include <stdbool.h>
#include "esp_err.h"

esp_err_t slab_buzzer_init(void);
/* Non-blocking burst at CONFIG_SLAB_CLICK_HZ and CONFIG_SLAB_CLICK_DUTY_PCT. */
void slab_buzzer_click(unsigned duration_us);
/* `count` bursts (at most 3) of on_us, one every period_us: one click per scroll step. */
void slab_buzzer_clicks(unsigned count, unsigned on_us, unsigned period_us);
/* Continuous tone; hz 0 or duty 0 stops it. */
esp_err_t slab_buzzer_tone(unsigned hz, unsigned duty_pct);
