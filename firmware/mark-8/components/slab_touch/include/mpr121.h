#pragma once
/* MPR121 at 0x5B on the slab: ELE0 = centre pad, ELE1 to ELE8 = ring sectors
 * clockwise from 12 o'clock seen from the front (SPEC 4, design.py
 * SECTOR_ANGLES). Register values follow hardware README "Firmware for the
 * touch wheel" item 4; tests/verify.py checks the table against that text. */
#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>

#define MPR121_ELECTRODES 9          /* ELE0 to ELE8 */
#define MPR121_REG_TOUCH_STATUS 0x00
#define MPR121_REG_OOR_STATUS   0x02
#define MPR121_REG_FILTERED     0x04
#define MPR121_REG_BASELINE     0x1E
#define MPR121_REG_MHDR         0x2B
#define MPR121_REG_TOUCH_TH0    0x41
#define MPR121_REG_DEBOUNCE     0x5B
#define MPR121_REG_AFE1         0x5C
#define MPR121_REG_AFE2         0x5D
#define MPR121_REG_ECR          0x5E
#define MPR121_REG_ACCR0        0x7B
#define MPR121_REG_USL          0x7D
#define MPR121_REG_LSL          0x7E
#define MPR121_REG_TL           0x7F
#define MPR121_REG_SOFT_RESET   0x80
#define MPR121_SOFT_RESET_VALUE 0x63
#define MPR121_AFE2_RESET_VALUE 0x24 /* 0x5D after a soft reset */

/* ECR: CL = 10 (baseline tracking, initial baseline from the 5 high bits of
 * the data, matching BVA = 10 in 0x7B), no proximity, ELE0 to ELE8. */
#define MPR121_ECR_RUN          0x89
/* After the first autoconfig: CL = 00 keeps the learned baselines when the
 * firmware stops the MPR121 for other I2C traffic and starts it again. */
#define MPR121_ECR_RESUME       0x09
#define MPR121_ECR_STOP         0x00
#define MPR121_ACCR0_AUTOCONFIG 0x8B /* FFI 18, BVA 10, ARE, ACE (README) */
#define MPR121_ACCR0_KEEP       0x8A /* same, ACE off: no new autoconfig on resume */

/* One burst read 0x00 to 0x26: status, out-of-range, filtered ELE0 to ELE12,
 * baseline ELE0 to ELE8. */
#define MPR121_FRAME_BYTES 0x27

typedef struct { uint8_t reg, value; } mpr121_reg_t;

typedef struct {
    uint8_t touch[MPR121_ELECTRODES], release[MPR121_ELECTRODES];
    bool slow_falling_baseline;   /* bench filter v2 instead of AN3944 */
} mpr121_settings_t;

typedef struct {
    uint16_t touched;                       /* bit i: ELEi touched */
    bool overcurrent;
    uint16_t oor;                           /* out-of-range bits, ACFF bit 15, ARFF bit 14 */
    uint16_t filtered[MPR121_ELECTRODES];   /* 10-bit */
    uint16_t baseline[MPR121_ELECTRODES];   /* 10-bit scale (register << 2) */
    int16_t delta[MPR121_ELECTRODES];       /* baseline - filtered; positive when touched */
} mpr121_frame_t;

/* Pure (host-tested). */
void mpr121_default_settings(mpr121_settings_t *s, uint8_t touch, uint8_t release);
/* The run-mode configuration, written in stop mode, in order. Ends with
 * the autoconfig registers; the caller then writes MPR121_ECR_RUN. */
size_t mpr121_config_table(const mpr121_settings_t *s, mpr121_reg_t *out, size_t max);
/* Sleep scan: SFI 4, ESI from esi_ms (rounded down to a power of two). */
uint8_t mpr121_afe2_value(unsigned sfi_code, unsigned esi_ms);
void mpr121_parse(const uint8_t raw[MPR121_FRAME_BYTES], mpr121_frame_t *out);

/* Driver (ESP-IDF, uses slab_i2c). */
#include "esp_err.h"
/* Soft reset, check the reset value, write the table, read it back,
 * start with autoconfig, check that autoconfig passed. */
esp_err_t mpr121_start(const mpr121_settings_t *s);
esp_err_t mpr121_read_frame(mpr121_frame_t *out);
/* Thresholds need stop mode; this stops, writes and resumes with baselines kept. */
esp_err_t mpr121_set_thresholds(const uint8_t touch[MPR121_ELECTRODES], const uint8_t release[MPR121_ELECTRODES]);
esp_err_t mpr121_stop(void);
esp_err_t mpr121_resume(void);
/* After a touch wake the finger may still be on the wheel. Waits, by
 * TOUCH_IRQ edges rather than polling the bus, until nothing is touched, so
 * the next mpr121_start learns untouched baselines. */
bool mpr121_wait_untouched(unsigned timeout_ms);
/* Deep sleep: run_slowly keeps scanning every esi_ms (touch wake), otherwise stop mode. */
esp_err_t mpr121_sleep(bool run_slowly, unsigned esi_ms);
