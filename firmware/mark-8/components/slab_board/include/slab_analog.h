#pragma once
/* VBAT_SENSE (GPIO35, ADC1 ch 7, 1M / 1M) and VBUS_SENSE (GPIO36, ADC1 ch 0,
 * 100k / 150k). Both are ADC1, so they work while Bluetooth runs. */
#include <stdbool.h>
#include "esp_err.h"

#define SLAB_VBUS_PRESENT_MV 4300
#define SLAB_D1_DROP_MV      350   /* B5819W at the backlight and system load */
#define SLAB_Q3_BODY_DIODE_MV 700

/* Pure helpers (host-tested). */
unsigned slab_divider_mv(unsigned pin_mv, unsigned ratio_x1000);
bool slab_vbus_present(unsigned vbus_mv);
/* VSYS is VBUS through D1 on USB (Q3 off; its body diode clamps VSYS at
 * VBAT - 0.7 V), and VBAT through Q3 on battery. */
unsigned slab_vsys_estimate_mv(unsigned vbus_mv, unsigned vbat_mv);

esp_err_t slab_analog_init(void);
/* Averaged, calibrated, scaled to the rail. -1 when the ADC is unavailable. */
int slab_analog_vbat_mv(void);
int slab_analog_vbus_mv(void);
