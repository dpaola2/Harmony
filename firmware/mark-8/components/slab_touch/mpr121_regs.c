/* MPR121 register table and frame parsing. Pure, host-tested.
 * Values: hardware/mark-8/slab-rev-a/README.md "Firmware for the touch wheel"
 * item 4 (NXP AN3944 quick-start baseline filter, autoconfig for 3.3 V). */
#include "mpr121.h"

void mpr121_default_settings(mpr121_settings_t *s, uint8_t touch, uint8_t release)
{
    for (unsigned i = 0; i < MPR121_ELECTRODES; ++i) { s->touch[i] = touch; s->release[i] = release; }
    s->slow_falling_baseline = false;
}

size_t mpr121_config_table(const mpr121_settings_t *s, mpr121_reg_t *out, size_t max)
{
    size_t n = 0;
#define PUT(r, v) do { if (n < max) out[n] = (mpr121_reg_t){(uint8_t)(r), (uint8_t)(v)}; ++n; } while (0)
    /* Baseline filter: rising, falling, touched (0x2B to 0x35). */
    PUT(0x2B, 0x01);   /* MHDR */
    PUT(0x2C, 0x01);   /* NHDR */
    PUT(0x2D, 0x0E);   /* NCLR */
    PUT(0x2E, 0x00);   /* FDLR */
    PUT(0x2F, 0x01);   /* MHDF */
    if (s->slow_falling_baseline) {
        PUT(0x30, 0x01); PUT(0x31, 0x20); PUT(0x32, 0x10);   /* bench filter v2 */
    } else {
        PUT(0x30, 0x05);   /* NHDF */
        PUT(0x31, 0x01);   /* NCLF */
        PUT(0x32, 0x00);   /* FDLF */
    }
    PUT(0x33, 0x00);   /* NHDT */
    PUT(0x34, 0x00);   /* NCLT */
    PUT(0x35, 0x00);   /* FDLT */
    /* Touch and release thresholds, ELE0 to ELE8. */
    for (unsigned i = 0; i < MPR121_ELECTRODES; ++i) {
        PUT(MPR121_REG_TOUCH_TH0 + 2 * i, s->touch[i]);
        PUT(MPR121_REG_TOUCH_TH0 + 2 * i + 1, s->release[i]);
    }
    PUT(MPR121_REG_DEBOUNCE, 0x22);   /* DR 2, DT 2 */
    PUT(MPR121_REG_AFE1, 0x90);       /* FFI 18 samples (bits 7:6 = 10), CDC 16 uA until autoconfig */
    PUT(MPR121_REG_AFE2, 0x2C);       /* CDT 0.5 us until autoconfig, SFI 6 (01), ESI 16 ms (100) */
    PUT(MPR121_REG_USL, 0xC9);        /* (3.3 - 0.7) / 3.3 x 256 */
    PUT(MPR121_REG_LSL, 0x82);        /* USL x 0.65 */
    PUT(MPR121_REG_TL, 0xB5);         /* USL x 0.9 */
    PUT(MPR121_REG_ACCR0, MPR121_ACCR0_AUTOCONFIG);
#undef PUT
    return n;
}

uint8_t mpr121_afe2_value(unsigned sfi_code, unsigned esi_ms)
{
    unsigned esi = 0;
    while (esi < 7 && (2u << esi) <= esi_ms) ++esi;
    return (uint8_t)((1u << 5) | ((sfi_code & 3u) << 3) | esi);   /* CDT field 0.5 us (autoconfig owns it) */
}

void mpr121_parse(const uint8_t raw[MPR121_FRAME_BYTES], mpr121_frame_t *out)
{
    out->touched = (uint16_t)((raw[0] | raw[1] << 8) & 0x1FFF);
    out->overcurrent = (raw[1] & 0x80) != 0;
    out->oor = (uint16_t)(raw[2] | raw[3] << 8);
    for (unsigned i = 0; i < MPR121_ELECTRODES; ++i) {
        out->filtered[i] = (uint16_t)(raw[MPR121_REG_FILTERED + 2 * i] | (raw[MPR121_REG_FILTERED + 2 * i + 1] & 0x03) << 8);
        out->baseline[i] = (uint16_t)(raw[MPR121_REG_BASELINE + i] << 2);
        out->delta[i] = (int16_t)(out->baseline[i] - out->filtered[i]);
    }
}
