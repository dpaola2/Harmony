#pragma once
/* VBAT_SENSE (GPIO35, ADC1 ch 7, 1M / 1M) and VBUS_SENSE (GPIO36, ADC1 ch 0,
 * 100k / 75k: 5.25 V gives 2.25 V at the pin). Both are ADC1, so they work
 * while Bluetooth runs. GPIO36 has no filter capacitor, so every reading is the
 * mean of 16 conversions (change review Q4-5). */
#include <stdbool.h>
#include "esp_err.h"

#define SLAB_VBUS_PRESENT_MV 4300   /* 1.84 V at the pin */
#define SLAB_D1_DROP_MV      350   /* B5819W at the backlight and system load */
#define SLAB_Q3_BODY_DIODE_MV 700

/* Battery limits (review PWR-6). Under the peak load the ESP32 needs VBAT of
 * 3.36 to 3.46 V to keep 3V3 at 3.0 V, so the player saves and sleeps at 3.45 V
 * under load, and a wake without USB goes back to sleep below 3.5 V. */
#define SLAB_BAT_CUTOFF_MV     3450
#define SLAB_BAT_CUTOFF_POLLS  5      /* consecutive once-a-second readings */
#define SLAB_BAT_WAKE_MIN_MV   3500
/* With USB in, VBAT_SENSE under 2 V for 10 s means a reversed pack: Q2 blocks
 * it only on battery power (review PWR-2). */
#define SLAB_BAT_REVERSED_MV   2000
#define SLAB_BAT_REVERSED_POLLS 10

typedef struct { unsigned low_polls, reversed_polls; } slab_bat_guard_t;
typedef enum { SLAB_BAT_OK, SLAB_BAT_EMPTY, SLAB_BAT_REVERSED } slab_bat_state_t;

/* Pure helpers (host-tested). */
unsigned slab_divider_mv(unsigned pin_mv, unsigned ratio_x1000);
bool slab_vbus_present(unsigned vbus_mv);
/* VSYS is VBUS through D1 on USB (Q3 off; its body diode clamps VSYS at
 * VBAT - 0.7 V), and VBAT through Q3 on battery. */
unsigned slab_vsys_estimate_mv(unsigned vbus_mv, unsigned vbat_mv);
/* One reading a second. EMPTY after SLAB_BAT_CUTOFF_POLLS low readings in a row
 * on battery; REVERSED after SLAB_BAT_REVERSED_POLLS readings under 2 V on USB. */
slab_bat_state_t slab_bat_guard_poll(slab_bat_guard_t *g, unsigned vbat_mv, bool usb);
/* False when a wake without USB finds the cell below SLAB_BAT_WAKE_MIN_MV. */
bool slab_bat_wake_allowed(unsigned vbat_mv, bool usb);

esp_err_t slab_analog_init(void);
/* Averaged, calibrated, scaled to the rail. -1 when the ADC is unavailable. */
int slab_analog_vbat_mv(void);
int slab_analog_vbus_mv(void);
