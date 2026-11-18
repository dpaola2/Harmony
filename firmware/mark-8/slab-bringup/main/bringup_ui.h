#pragma once
/* Bring-up screen pages. Pure renderers into a 320 x 320 RGB565 frame. */
#include <stdbool.h>
#include <stdint.h>
#include "noise_stats.h"

typedef enum { BU_NOT_RUN, BU_PASS, BU_FAIL, BU_SKIP } bu_status_t;
enum {
    BU_BOOT, BU_VBUS, BU_I2C, BU_BATTERY, BU_HAPTIC, BU_TOUCH, BU_PERIPH, BU_SCREEN,
    BU_CARD, BU_NOISE, BU_BUTTON, BU_BUZZER, BU_WHEEL, BU_WAKE_BUTTON, BU_WAKE_TOUCH, BU_COUNT
};
typedef struct { uint8_t status; char detail[96]; } bu_result_t;
extern const char *const bu_names[BU_COUNT];
const char *bu_status_text(uint8_t status);

#define BU_NOISE_CASES 8
typedef struct {
    noise_case_t cases[BU_NOISE_CASES];
    unsigned count;
    int chosen;
    uint8_t touch[NOISE_ELECTRODES], release[NOISE_ELECTRODES];
} bu_noise_table_t;

typedef struct {
    int16_t delta[9];
    uint16_t touched, seen;
    bool has_angle;
    float angle_deg;
    const char *zone;
    float turn_deg;
    long steps;
    unsigned updates;
    bool turn_done, centre_tap;
    int16_t peak[9];
    uint8_t touch_th[9];
} bu_wheel_view_t;

void bu_render_bars(uint16_t *fb, const char *prompt);
void bu_render_results(uint16_t *fb, const bu_result_t *r, const char *prompt);
void bu_render_noise(uint16_t *fb, const bu_noise_table_t *t, const char *prompt);
void bu_render_wheel(uint16_t *fb, const bu_wheel_view_t *w, const char *prompt);
