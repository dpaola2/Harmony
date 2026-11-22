#pragma once
/* Backlight: 10 white LEDs in parallel from VSYS through R17 (10 ohm, 1206,
 * 0.25 W), switched on the low side by Q5 (GPIO4 PWM).
 * Hardware README "Power" note 3: about 120 mA at 4.2 V battery and about
 * 170 mA on USB (VSYS 4.7 V) at 100 percent duty, up to about 220 mA with a
 * low-VF panel on a 5.25 V port; keep the duty at or below 80 percent on USB,
 * and compute the R17 power cap from the worst case, not the brightness model
 * (review PERIPH-2). LCD_LEDA runs behind the touch wheel and swings at the
 * PWM rate, so the frequency is a config value chosen by the bring-up noise
 * table. */
#include <stdbool.h>
#include <stdint.h>
#include "esp_err.h"

/* Brightness model: I = (VSYS - VF0) / (R17 + r_led). Fits both README points. */
#define SLAB_BL_VF0_MV        2800
#define SLAB_BL_R_MOHM        11500   /* 10 ohm R17 + about 1.5 ohm for 10 LEDs in parallel */
#define SLAB_BL_REF_VSYS_MV   3700    /* brightness 100 percent = full current at a 3.7 V cell */
#define SLAB_BL_MAX_PCT       100     /* brightness above the reference is not offered */
/* Power model for the R17 cap: the panel's minimum VF (2.7 V) and no LED
 * resistance, so the current is (VSYS - 2.7 V) / 10 ohm. */
#define SLAB_BL_WORST_VF_MV   2700
#define SLAB_BL_R17_MOHM      10000
#define SLAB_BL_P_MAX_MW      200     /* 80 percent of the 0.25 W rating, inside a closed case */
#define SLAB_BL_USB_MAX_PERMILLE 800
#define SLAB_BL_MIN_PERMILLE  10

typedef struct {
    unsigned duty_permille;  /* 0 to 1000 */
    unsigned full_ma;        /* LED current while the switch is on */
    unsigned avg_ma;         /* average LED current */
    unsigned r17_mw;         /* average power in R17, worst-case model */
    bool limited;            /* target not reachable (low VSYS) or capped */
} slab_bl_plan_t;

/* Pure (host-tested). */
unsigned slab_bl_full_ma(unsigned vsys_mv);
unsigned slab_bl_worst_ma(unsigned vsys_mv);
slab_bl_plan_t slab_bl_plan(unsigned brightness_pct, unsigned vsys_mv, bool usb);

/* LEDC on GPIO4. 1000 permille holds the pin high (no edges); 0 holds it low. */
esp_err_t slab_backlight_init(uint32_t pwm_hz);
esp_err_t slab_backlight_set_freq(uint32_t pwm_hz);
uint32_t slab_backlight_freq(void);
esp_err_t slab_backlight_set_permille(unsigned duty_permille);
unsigned slab_backlight_permille(void);
