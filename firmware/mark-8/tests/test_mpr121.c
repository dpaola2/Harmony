/* MPR121 register setup and frame parsing. Prints the register table
 * ("REG 0xNN 0xVV") for tests/verify.py to check against the hardware README. */
#include <assert.h>
#include <stdio.h>
#include <string.h>
#include "mpr121.h"

static int find(const mpr121_reg_t *t, size_t n, uint8_t reg)
{
    for (size_t i = 0; i < n; ++i) if (t[i].reg == reg) return t[i].value;
    return -1;
}

int main(void)
{
    mpr121_settings_t s;
    mpr121_default_settings(&s, 12, 6);
    mpr121_reg_t t[64];
    size_t n = mpr121_config_table(&s, t, 64);
    assert(n > 0 && n <= 48);   /* the driver's table buffer is 48 */
    for (size_t i = 0; i < n; ++i) {
        printf("REG 0x%02X 0x%02X\n", t[i].reg, t[i].value);
        for (size_t j = 0; j < i; ++j) assert(t[j].reg != t[i].reg);   /* each register once */
        assert(t[i].reg != MPR121_REG_ECR);   /* ECR last, by the caller, after the table */
    }
    printf("ECR_RUN 0x%02X\nECR_RESUME 0x%02X\nACCR0_KEEP 0x%02X\n", MPR121_ECR_RUN, MPR121_ECR_RESUME, MPR121_ACCR0_KEEP);
    /* Autoconfig is the last write, so its FFI and the AFE FFI agree when it runs. */
    assert(t[n - 1].reg == MPR121_REG_ACCR0);
    assert((find(t, n, 0x7B) >> 6) == (find(t, n, 0x5C) >> 6));
    /* ECR calibration lock bits equal the autoconfig baseline value bits (BVA). */
    assert((MPR121_ECR_RUN >> 6) == ((MPR121_ACCR0_AUTOCONFIG >> 2) & 3));
    assert((MPR121_ECR_RUN & 0x0F) == 9 && (MPR121_ECR_RESUME & 0x0F) == 9 && (MPR121_ECR_RESUME >> 6) == 0);
    assert(MPR121_ACCR0_KEEP == (MPR121_ACCR0_AUTOCONFIG & ~1));
    /* Per-electrode thresholds land on 0x41 + 2i and 0x42 + 2i. */
    uint8_t touch[9] = {12, 13, 14, 15, 16, 17, 18, 19, 20}, release[9] = {6, 6, 7, 7, 8, 8, 9, 9, 10};
    memcpy(s.touch, touch, 9); memcpy(s.release, release, 9);
    n = mpr121_config_table(&s, t, 64);
    for (int i = 0; i < 9; ++i) assert(find(t, n, 0x41 + 2 * i) == touch[i] && find(t, n, 0x42 + 2 * i) == release[i]);
    assert(find(t, n, 0x41 + 18) == -1);   /* ELE9 to ELE11 unused */
    /* Bench filter v2 changes only the falling filter. */
    mpr121_reg_t v2[64];
    s.slow_falling_baseline = true;
    size_t n2 = mpr121_config_table(&s, v2, 64);
    assert(n2 == n);
    for (size_t i = 0; i < n; ++i) {
        bool falling = v2[i].reg >= 0x30 && v2[i].reg <= 0x32;
        assert(v2[i].reg == t[i].reg && (falling || v2[i].value == t[i].value));
    }
    assert(find(v2, n2, 0x30) == 1 && find(v2, n2, 0x31) == 32 && find(v2, n2, 0x32) == 16);
    /* A short table buffer reports the full size and writes nothing past it. */
    mpr121_reg_t small[4];
    memset(small, 0xEE, sizeof(small));
    assert(mpr121_config_table(&s, small, 3) == n && small[3].reg == 0xEE);
    /* Sleep scan register: SFI 4, ESI 16/32/64/128 ms. */
    assert(mpr121_afe2_value(1, 16) == 0x2C);
    assert(mpr121_afe2_value(0, 64) == 0x26 && mpr121_afe2_value(0, 128) == 0x27 && mpr121_afe2_value(0, 32) == 0x25);
    assert(mpr121_afe2_value(0, 100) == 0x26 && mpr121_afe2_value(0, 1) == 0x20);
    /* Frame parsing: status, overcurrent, OOR, 10-bit filtered, baseline x4, delta. */
    uint8_t raw[MPR121_FRAME_BYTES] = {0};
    raw[0] = 0x05; raw[1] = 0x81;           /* ELE0, ELE2, ELE8, overcurrent */
    raw[2] = 0x00; raw[3] = 0x80;           /* ACFF */
    raw[4] = 0x34; raw[5] = 0x02;           /* ELE0 filtered 0x234 = 564 */
    raw[4 + 16] = 0xFF; raw[4 + 17] = 0xFF; /* ELE8: only 10 bits count */
    raw[0x1E] = 150;                         /* ELE0 baseline 600 */
    raw[0x1E + 8] = 0xFF;
    mpr121_frame_t f;
    mpr121_parse(raw, &f);
    assert(f.touched == 0x105 && f.overcurrent && (f.oor & 0x8000));
    assert(f.filtered[0] == 564 && f.baseline[0] == 600 && f.delta[0] == 36);
    assert(f.filtered[8] == 1023 && f.baseline[8] == 1020 && f.delta[8] == -3);
    puts("PASS MPR121: register table (one write each, autoconfig last, FFI and BVA consistent), thresholds per electrode, "
         "bench v2 option, sleep scan values, frame parsing");
    return 0;
}
