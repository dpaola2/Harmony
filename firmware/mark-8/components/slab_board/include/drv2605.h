#pragma once
/* DRV2605L haptic driver at 0x5A. EN is tied to 3V3 through 10k and IN/TRIG
 * to GND, so the part is always enabled and starts in standby (MODE 0x40).
 * The motor (LCM1027A2445F, a 10 mm ERM coin) is optional: run effects only
 * when CONFIG_SLAB_MOTOR_FITTED is set. */
#include <stdbool.h>
#include <stdint.h>
#include "esp_err.h"

#define DRV2605_REG_STATUS   0x00
#define DRV2605_REG_MODE     0x01
#define DRV2605_REG_LIBRARY  0x03
#define DRV2605_REG_WAVESEQ1 0x04
#define DRV2605_REG_WAVESEQ2 0x05
#define DRV2605_REG_GO       0x0C
#define DRV2605_REG_FEEDBACK 0x1A
#define DRV2605_REG_CONTROL3 0x1D
#define DRV2605L_DEVICE_ID   7
#define DRV2605_EFFECT_STRONG_CLICK 1
#define DRV2605_EFFECT_SHARP_TICK   24

/* Pure: device ID is STATUS bits 7:5. */
static inline unsigned drv2605_device_id(uint8_t status) { return status >> 5; }

/* Reads STATUS; true when a DRV2605L answers. *id gets the device ID. */
bool drv2605_detect(unsigned *id);
/* ERM, open loop, library 1 (Adafruit DRV2605 defaults), then standby. */
esp_err_t drv2605_setup_erm(void);
esp_err_t drv2605_play(uint8_t effect);
esp_err_t drv2605_standby(void);
