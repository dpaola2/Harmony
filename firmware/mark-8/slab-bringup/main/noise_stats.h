#pragma once
/* Touch-noise statistics for the backlight noise table. Pure, host-tested. */
#include <stdbool.h>
#include <stdint.h>

#define NOISE_ELECTRODES 9
#define NOISE_MIN_TOUCH 12        /* README: start at touch 12, release 6 */
#define NOISE_THRESHOLD_FACTOR 3  /* README: at least 3 x peak-to-peak */
#define NOISE_PASS_MAX_TOUCH 24   /* a threshold above this leaves little room for a touch */

typedef struct { uint16_t min[NOISE_ELECTRODES], max[NOISE_ELECTRODES]; unsigned n; } noise_acc_t;

typedef struct {
    char label[18];
    uint32_t pwm_hz;              /* 0: no PWM edges */
    uint16_t duty_permille;
    bool pwm_case;                /* a candidate backlight PWM setting */
    bool activity;                /* screen, card or buzzer running too */
    bool skipped;
    uint8_t pp[NOISE_ELECTRODES]; /* peak-to-peak filtered data, counts */
    uint8_t worst;
    uint16_t irqs;                /* TOUCH_IRQ edges during the case: false touches */
    uint16_t samples;
} noise_case_t;

void noise_reset(noise_acc_t *a);
void noise_add(noise_acc_t *a, const uint16_t filtered[NOISE_ELECTRODES]);
void noise_finish(const noise_acc_t *a, noise_case_t *c);
/* Index of the quietest PWM case: lowest worst electrode, then lowest sum,
 * then the higher frequency. -1 when there is none. */
int noise_quietest(const noise_case_t *cases, unsigned n);
/* Per electrode: touch = max(12, 3 x worst pp over the cases that count),
 * release = touch / 2. The cases that count are the chosen PWM case and the
 * activity cases (run at that PWM setting). Returns false if any touch
 * threshold exceeds NOISE_PASS_MAX_TOUCH. */
bool noise_thresholds(const noise_case_t *cases, unsigned n, int chosen,
                      uint8_t touch[NOISE_ELECTRODES], uint8_t release[NOISE_ELECTRODES],
                      uint8_t worst[NOISE_ELECTRODES]);
