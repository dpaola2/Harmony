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
/* Sustained tones heat R18 (33 ohm, 0805, 0.125 W): at 50 percent duty it
 * averages 0.14 to 0.18 W, and with GPIO2 held high 0.36 W (review FP-5,
 * PERIPH-3). So a tone runs only near the buzzer's 4 kHz resonance, at 25
 * percent duty or less, and stops by itself after SLAB_TONE_MAX_MS. GPIO2 is
 * never held high: the LEDC duty never exceeds 50 percent. */
#define SLAB_TONE_MIN_HZ       3000
#define SLAB_TONE_MAX_HZ       5000
#define SLAB_TONE_MAX_DUTY_PCT 25
#define SLAB_TONE_MAX_MS       60000   /* the longest bring-up noise case is about 42 s */
/* Continuous tone; hz 0 or duty 0 stops it. A frequency outside SLAB_TONE_MIN_HZ
 * to SLAB_TONE_MAX_HZ returns ESP_ERR_INVALID_ARG and leaves the buzzer off. */
esp_err_t slab_buzzer_tone(unsigned hz, unsigned duty_pct);
