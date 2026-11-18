#pragma once
/* MAX17048 fuel gauge at 0x36 (CELL and VDD on VBAT, QSTRT and CTG to GND). */
#include <stdbool.h>
#include <stdint.h>
#include "esp_err.h"

#define MAX17048_REG_VCELL   0x02
#define MAX17048_REG_SOC     0x04
#define MAX17048_REG_MODE    0x06
#define MAX17048_REG_VERSION 0x08
#define MAX17048_REG_HIBRT   0x0A
#define MAX17048_REG_CONFIG  0x0C
#define MAX17048_REG_CRATE   0x16
#define MAX17048_HIBRT_DEFAULT 0x8030
#define MAX17048_HIBRT_ALWAYS  0xFFFF

typedef struct {
    uint16_t version;
    unsigned vcell_mv;      /* cell voltage */
    unsigned soc_x256;      /* state of charge, 1/256 percent */
    unsigned percent;       /* rounded, 0 to 100 */
    int crate_pct_x1000;    /* charge rate, thousandths of a percent per hour */
} max17048_reading_t;

/* Pure conversions (host-tested). Register bytes are big-endian. */
unsigned max17048_vcell_mv(uint16_t raw);        /* 78.125 uV per LSB */
unsigned max17048_percent(uint16_t soc_raw);     /* high byte percent, low byte 1/256 */
int max17048_crate(uint16_t raw);                /* 0.208 percent per hour per LSB, signed */
bool max17048_version_ok(uint16_t version);      /* 0x001x */
void max17048_parse(const uint8_t vcell[2], const uint8_t soc[2], const uint8_t crate[2],
                    uint16_t version, max17048_reading_t *out);

esp_err_t max17048_read(max17048_reading_t *out);
/* true forces hibernate (lowest current, for deep sleep); false restores the default thresholds. */
esp_err_t max17048_hibernate(bool force);
