#pragma once
/* Backlight: 10 white LEDs in parallel from VSYS through R17 (10 ohm, 1206,
 * 0.25 W), switched on the low side by Q5 (GPIO4 PWM).
 * Hardware README "Power" note 3: about 120 mA at 4.2 V battery and about
 * 170 mA on USB (VSYS 4.7 V) at 100 percent duty; keep the duty at or below
 * 80 percent on USB. LCD_LEDA runs behind the touch wheel and swings at the
 * PWM rate, so the frequency is a config value chosen by the bring-up noise
 * table. */
#include <stdbool.h>
#include <stdint.h>
#include "esp_err.h"

/* LED model: I = (VSYS - VF0) / (R17 + r_led). Fits both README points. */
#define SLAB_BL_VF0_MV        2800
#define SLAB_BL_R_MOHM        11500   /* 10 ohm R17 + about 1.5 ohm for 10 LEDs in parallel */
#define SLAB_BL_R17_MOHM      10000
#define SLAB_BL_REF_VSYS_MV   3700    /* brightness 100 percent = full current at a 3.7 V cell */
#define SLAB_BL_P_MAX_MW      231     /* 0.8 x (170 mA)^2 x 10 ohm: the README's USB limit as power */
#define SLAB_BL_USB_MAX_PERMILLE 800
#define SLAB_BL_MIN_PERMILLE  10

typedef struct {
    unsigned duty_permille;  /* 0 to 1000 */
    unsigned full_ma;        /* LED current while the switch is on */
    unsigned avg_ma;         /* average LED current */
    unsigned r17_mw;         /* average power in R17 */
    bool limited;            /* target not reachable (low VSYS) or capped */
} slab_bl_plan_t;

/* Pure (host-tested). */
unsigned slab_bl_full_ma(unsigned vsys_mv);
slab_bl_plan_t slab_bl_plan(unsigned brightness_pct, unsigned vsys_mv, bool usb);

/* LEDC on GPIO4. 1000 permille holds the pin high (no edges); 0 holds it low. */
esp_err_t slab_backlight_init(uint32_t pwm_hz);
esp_err_t slab_backlight_set_freq(uint32_t pwm_hz);
uint32_t slab_backlight_freq(void);
esp_err_t slab_backlight_set_permille(unsigned duty_permille);
unsigned slab_backlight_permille(void);
