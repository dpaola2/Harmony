#pragma once
/* Board calibration that the bring-up test measures and the player uses,
 * kept in NVS namespace "slab_cal". Both projects use the same partition
 * table, and `idf.py flash` does not erase NVS, so the player finds what the
 * bring-up saved. */
#include <stdbool.h>
#include <stdint.h>
#include "esp_err.h"

#define SLAB_CAL_ELECTRODES 9

typedef struct {
    uint32_t bl_pwm_hz;                      /* quietest backlight PWM frequency */
    uint8_t touch[SLAB_CAL_ELECTRODES];      /* MPR121 touch threshold per electrode */
    uint8_t release[SLAB_CAL_ELECTRODES];    /* MPR121 release threshold per electrode */
    uint8_t worst_pp[SLAB_CAL_ELECTRODES];   /* worst peak-to-peak noise seen, counts */
} slab_cal_t;

/* nvs_flash_init must have run. false when nothing is saved. */
bool slab_cal_load(slab_cal_t *out);
esp_err_t slab_cal_save(const slab_cal_t *cal);
