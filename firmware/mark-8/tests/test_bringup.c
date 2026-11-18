/* Bring-up: noise statistics, threshold choice, changed-region finder, and
 * the four screen pages rendered to PPM for the preview PNGs. */
#include <assert.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "bringup_ui.h"
#include "gfx.h"
#include "noise_stats.h"
#include "slab_dirty.h"

static const char *outdir;
static void save(const char *name, const uint16_t *f)
{
    if (!outdir) return;
    char path[512];
    snprintf(path, sizeof(path), "%s/%s.ppm", outdir, name);
    FILE *o = fopen(path, "wb");
    assert(o);
    fprintf(o, "P6\n%d %d\n255\n", GFX_W, GFX_H);
    for (int i = 0; i < GFX_W * GFX_H; ++i) {
        unsigned c = f[i];
        unsigned char rgb[] = {(unsigned char)(((c >> 11) & 31) * 255 / 31), (unsigned char)(((c >> 5) & 63) * 255 / 63),
                               (unsigned char)((c & 31) * 255 / 31)};
        fwrite(rgb, 1, 3, o);
    }
    fclose(o);
}

static noise_case_t make(const char *label, uint32_t hz, bool pwm, bool activity, const uint8_t pp[9])
{
    noise_case_t c;
    memset(&c, 0, sizeof(c));
    snprintf(c.label, sizeof(c.label), "%s", label);
    c.pwm_hz = hz; c.pwm_case = pwm; c.activity = activity; c.duty_permille = 500; c.samples = 24;
    memcpy(c.pp, pp, 9);
    for (int e = 0; e < 9; ++e) if (pp[e] > c.worst) c.worst = pp[e];
    return c;
}

static void test_noise(void)
{
    noise_acc_t acc;
    noise_reset(&acc);
    uint16_t f[9];
    for (int k = 0; k < 24; ++k) {
        for (int e = 0; e < 9; ++e) f[e] = (uint16_t)(600 + e * 10 + (k % 3) * (e % 3));
        noise_add(&acc, f);
    }
    noise_case_t c;
    memset(&c, 0, sizeof(c));
    noise_finish(&acc, &c);
    assert(c.samples == 24 && c.pp[0] == 0 && c.pp[1] == 2 && c.pp[2] == 4 && c.worst == 4);
    noise_reset(&acc);
    noise_finish(&acc, &c);
    assert(c.samples == 0 && c.worst == 0);
    /* Quietest PWM case: lowest worst electrode, then lowest sum, then the higher frequency. */
    noise_case_t cases[8] = {
        make("BL off", 0, false, false, (uint8_t[]){1, 1, 1, 1, 1, 1, 1, 1, 1}),
        make("BL 100%", 0, false, false, (uint8_t[]){1, 1, 1, 1, 1, 1, 1, 1, 1}),
        make("50% 1kHz", 1000, true, false, (uint8_t[]){2, 6, 2, 2, 2, 2, 2, 2, 2}),
        make("50% 20kHz", 20000, true, false, (uint8_t[]){2, 2, 3, 2, 2, 2, 2, 2, 2}),
        make("50% 40kHz", 40000, true, false, (uint8_t[]){2, 2, 3, 2, 2, 2, 2, 2, 2}),
        make("+screen", 40000, false, true, (uint8_t[]){2, 2, 3, 5, 2, 2, 2, 2, 2}),
        make("+card read", 40000, false, true, (uint8_t[]){2, 2, 3, 2, 2, 2, 2, 7, 2}),
        make("+buzzer", 40000, false, true, (uint8_t[]){2, 2, 3, 2, 2, 2, 2, 2, 2})};
    int q = noise_quietest(cases, 8);
    assert(q == 4);   /* 20 and 40 kHz tie on worst and sum: the higher frequency wins */
    cases[3].pp[0] = 1;
    assert(noise_quietest(cases, 5) == 3);   /* lower sum wins */
    cases[3].pp[0] = 2;
    cases[4].skipped = true;
    assert(noise_quietest(cases, 5) == 3);
    cases[4].skipped = false;
    uint8_t touch[9], release[9], worst[9];
    bool ok = noise_thresholds(cases, 8, q, touch, release, worst);
    /* E3: 5 counts with the screen running -> 15; E7: 7 with the card -> 21; others stay at 12. */
    assert(ok && touch[3] == 15 && touch[7] == 21 && touch[0] == 12 && release[7] == 10 && release[0] == 6);
    assert(worst[3] == 5 && worst[7] == 7 && worst[1] == 2);   /* 1 kHz case (6 on E1) does not count */
    cases[6].pp[7] = 9;
    assert(!noise_thresholds(cases, 8, q, touch, release, worst) && touch[7] == 27);
    cases[6].pp[7] = 200;
    noise_thresholds(cases, 8, q, touch, release, worst);
    assert(touch[7] == 254 && release[7] == 127);
    assert(noise_quietest(cases, 2) == -1);
    puts("PASS noise statistics: peak-to-peak, quietest PWM choice, 3x thresholds with the README minimum of 12/6");
}

static void test_dirty(void)
{
    enum { W = 40, H = 30 };
    static uint16_t a[W * H], b[W * H];
    slab_rect_t r[8];
    assert(slab_dirty_rects(a, b, W, H, 8, r, 8) == 0);
    b[3 * W + 5] = 1; b[12 * W + 30] = 1;           /* bands 0 and 1: one run */
    b[29 * W + 0] = 1;                             /* last, short band (rows 24 to 29) */
    unsigned n = slab_dirty_rects(a, b, W, H, 8, r, 8);
    assert(n == 2);
    assert(r[0].x == 5 && r[0].w == 26 && r[0].y == 0 && r[0].h == 16);
    assert(r[1].x == 0 && r[1].w == 1 && r[1].y == 24 && r[1].h == 6);
    assert(slab_rects_bytes(r, n, 11) == (26 * 16 + 6) * 2 + 22);
    for (unsigned i = 0; i < n; ++i) slab_rect_copy(a, b, W, &r[i]);
    assert(!memcmp(a, b, sizeof(a)));
    /* More runs than slots: the last slot grows to cover the rest. */
    memset(b, 0, sizeof(b)); memset(a, 0, sizeof(a));
    b[0] = 1; b[17 * W + 2] = 1; b[29 * W + 39] = 1;   /* bands 0, 2, 3 */
    n = slab_dirty_rects(a, b, W, H, 8, r, 2);
    assert(n == 2 && r[1].y == 16 && r[1].y + r[1].h == 30 && r[1].x == 2 && r[1].x + r[1].w == 40);
    puts("PASS changed-region finder: band runs, column spans, short last band, slot overflow");
}

int main(int argc, char **argv)
{
    outdir = argc > 1 ? argv[1] : NULL;
    test_noise();
    test_dirty();
    uint16_t *fb = calloc(GFX_W * GFX_H, 2);
    assert(fb);
    bu_render_bars(fb, "Arrow at the top edge, bars RED GREEN BLUE WHITE? Press for yes; wait 15 s for no.");
    /* The border reaches every edge pixel; the arrow tip points at the top edge. */
    for (int i = 0; i < GFX_W; ++i) assert(fb[i] == GFX_WHITE && fb[(GFX_H - 1) * GFX_W + i] == GFX_WHITE);
    for (int i = 0; i < GFX_H; ++i) assert(fb[i * GFX_W] == GFX_WHITE && fb[i * GFX_W + GFX_W - 1] == GFX_WHITE);
    assert(fb[30 * GFX_W + 160] == GFX_WHITE && fb[30 * GFX_W + 130] == GFX_BLACK && fb[70 * GFX_W + 130] == GFX_WHITE);
    assert(fb[190 * GFX_W + 40] == GFX_RED && fb[190 * GFX_W + 120] == GFX_GREEN && fb[190 * GFX_W + 200] == GFX_BLUE);
    save("bringup-screen", fb);
    bu_result_t r[BU_COUNT];
    memset(r, 0, sizeof(r));
    const struct { uint8_t s; const char *d; } sample[BU_COUNT] = {
        {BU_PASS, "ESP32-PICO-V3-02 rev 3.1, flash 8 MB"}, {BU_PASS, "5.04 V on VBUS_SENSE (USB present)"},
        {BU_PASS, "0x36 MAX17048, 0x5A DRV2605L, 0x5B MPR121"}, {BU_PASS, "divider 4.18 V, gauge 4.17 V, 98 %"},
        {BU_PASS, "DRV2605L id 7; no motor (config)"}, {BU_PASS, "36 regs verified, autoconfig ok"},
        {BU_PASS, "3V3_PERIPH off 12 mV, on 3104 mV"}, {BU_PASS, "init ok at 40 MHz, confirmed"},
        {BU_PASS, "29819 MB, 20 MHz, raw 1840 KB/s"}, {BU_PASS, "PWM 40000 Hz quietest, worst p-p 4"},
        {BU_PASS, "pressed for 180 ms"}, {BU_FAIL, "no confirmation: beeps not heard?"},
        {BU_PASS, "9/9 seen, turn ok, centre tap ok"}, {BU_NOT_RUN, ""}, {BU_NOT_RUN, ""}};
    for (int i = 0; i < BU_COUNT; ++i) { r[i].status = sample[i].s; snprintf(r[i].detail, sizeof(r[i].detail), "%s", sample[i].d); }
    bu_render_results(fb, r, "Deep sleep test: the screen goes dark. Press the side button to wake.");
    save("bringup-results", fb);
    bu_noise_table_t t;
    memset(&t, 0, sizeof(t));
    const char *labels[8] = {"BL off", "BL 100%", "50% 1kHz", "50% 20kHz", "50% 40kHz", "+screen", "+card read", "+buzzer"};
    for (int i = 0; i < 8; ++i) {
        uint8_t pp[9];
        for (int e = 0; e < 9; ++e) pp[e] = (uint8_t)(1 + (i == 2 ? 6 : 0) + (i >= 5 ? (e == 2 * (i - 5) + 1 ? 3 : 1) : 0) + (e % 2));
        t.cases[i] = make(labels[i], i == 2 ? 1000 : i == 3 ? 20000 : 40000, i >= 2 && i <= 4, i >= 5, pp);
    }
    t.count = 8;
    t.chosen = noise_quietest(t.cases, 8);
    uint8_t worst[9];
    noise_thresholds(t.cases, 8, t.chosen, t.touch, t.release, worst);
    bu_render_noise(fb, &t, "Noise table done. Saved for the player.");
    save("bringup-noise", fb);
    bu_wheel_view_t w;
    memset(&w, 0, sizeof(w));
    int16_t deltas[9] = {3, 2, 6, 41, 58, 12, 1, 0, 2};
    memcpy(w.delta, deltas, sizeof(deltas));
    w.touched = 0x18; w.seen = 0x1FE; w.has_angle = true; w.angle_deg = -32; w.zone = "NONE";
    w.turn_deg = 214; w.steps = 14; w.updates = 11;
    bu_render_wheel(fb, &w, "WHEEL: touch every sector, turn once clockwise, then tap the centre.");
    save("bringup-wheel", fb);
    free(fb);
    puts("PASS bring-up pages: colour bars with border and TOP arrow, results list, noise table, wheel view");
    return 0;
}
