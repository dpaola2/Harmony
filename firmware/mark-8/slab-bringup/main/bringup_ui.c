/* Bring-up screen pages. Pure; the host tests render them to preview PNG files. */
#include <math.h>
#include <stdio.h>
#include <string.h>
#include "bringup_ui.h"
#include "gfx.h"

#define HEADER GFX_RGB(23, 41, 25)
#define PANEL GFX_RGB(233, 237, 223)
#define INK GFX_RGB(23, 41, 25)
#define PASS_C GFX_RGB(40, 150, 60)
#define FAIL_C GFX_RGB(200, 40, 40)
#define PROMPT_Y 264

const char *const bu_names[BU_COUNT] = {
    "BOOT", "VBUS", "I2C", "BATTERY", "HAPTIC", "TOUCH", "PERIPH", "SCREEN",
    "CARD", "NOISE", "BUTTON", "BUZZER", "WHEEL", "WAKE_BTN", "WAKE_TCH"};

const char *bu_status_text(uint8_t s)
{
    return s == BU_PASS ? "PASS" : s == BU_FAIL ? "FAIL" : s == BU_SKIP ? "SKIP" : "----";
}

static void header(uint16_t *fb, const char *title)
{
    gfx_fill(fb, 0, 0, GFX_W, 20, HEADER);
    gfx_text(fb, 4, 2, title, GFX_WHITE, HEADER, 1);
}

/* Word-wrapped prompt, three lines of 39 characters at the bottom. */
static void prompt_area(uint16_t *fb, const char *prompt, uint16_t bg)
{
    gfx_fill(fb, 0, PROMPT_Y, GFX_W, GFX_H - PROMPT_Y, bg);
    if (!prompt) return;
    const char *p = prompt;
    for (int line = 0; line < 3 && *p; ++line) {
        char out[40];
        int n = (int)strlen(p);
        if (n > 39) {
            n = 39;
            while (n > 0 && p[n] != ' ') --n;
            if (n == 0) n = 39;
        }
        memcpy(out, p, (size_t)n);
        out[n] = 0;
        gfx_text(fb, 4, PROMPT_Y + 4 + 16 * line, out, INK, bg, 1);
        p += n;
        while (*p == ' ') ++p;
    }
}

void bu_render_bars(uint16_t *fb, const char *prompt)
{
    gfx_fill(fb, 0, 0, GFX_W, GFX_H, GFX_BLACK);
    /* Arrow toward the top edge, the end away from the wheel. */
    gfx_triangle(fb, 160, 22, 118, 74, 202, 74, GFX_WHITE);
    gfx_fill(fb, 146, 74, 28, 34, GFX_WHITE);
    gfx_text(fb, 136, 112, "TOP", GFX_WHITE, GFX_BLACK, 2);
    gfx_text(fb, 8, 8, "MARK-8", GFX_GREY, GFX_BLACK, 1);
    gfx_text(fb, 256, 8, "SLAB A", GFX_GREY, GFX_BLACK, 1);
    static const struct { uint16_t c; const char *name; } bars[] = {
        {GFX_RED, "RED"}, {GFX_GREEN, "GREEN"}, {GFX_BLUE, "BLUE"}, {GFX_WHITE, "WHITE"}};
    for (int i = 0; i < 4; ++i) {
        gfx_fill(fb, 8 + 76 * i, 150, 76, 80, bars[i].c);
        int len = (int)strlen(bars[i].name);
        gfx_text(fb, 8 + 76 * i + (76 - 8 * len) / 2, 236, bars[i].name, GFX_WHITE, GFX_BLACK, 1);
    }
    /* Grey ramp in 32 steps. */
    for (int i = 0; i < 32; ++i) gfx_fill(fb, 8 + i * 9, 138, 9, 8, GFX_RGB(i * 8, i * 8, i * 8));
    prompt_area(fb, prompt, PANEL);
    /* One-pixel border on the outermost rows and columns: a missing edge means a RAM offset. */
    gfx_fill(fb, 0, 0, GFX_W, 1, GFX_WHITE);
    gfx_fill(fb, 0, GFX_H - 1, GFX_W, 1, GFX_WHITE);
    gfx_fill(fb, 0, 0, 1, GFX_H, GFX_WHITE);
    gfx_fill(fb, GFX_W - 1, 0, 1, GFX_H, GFX_WHITE);
}

void bu_render_results(uint16_t *fb, const bu_result_t *r, const char *prompt)
{
    gfx_fill(fb, 0, 0, GFX_W, GFX_H, GFX_WHITE);
    header(fb, "HARMONY MARK-8 SLAB BRING-UP");
    for (int i = 0; i < BU_COUNT; ++i) {
        int y = 22 + 16 * i;
        uint8_t s = r[i].status;
        uint16_t c = s == BU_PASS ? PASS_C : s == BU_FAIL ? FAIL_C : s == BU_SKIP ? GFX_AMBER : GFX_GREY;
        gfx_text(fb, 4, y, bu_names[i], INK, GFX_WHITE, 1);
        gfx_text(fb, 76, y, bu_status_text(s), GFX_WHITE, c, 1);
        char detail[26];
        snprintf(detail, sizeof(detail), "%s", r[i].detail);
        gfx_text(fb, 116, y, detail, INK, GFX_WHITE, 1);
    }
    prompt_area(fb, prompt, PANEL);
}

void bu_render_noise(uint16_t *fb, const bu_noise_table_t *t, const char *prompt)
{
    gfx_fill(fb, 0, 0, GFX_W, GFX_H, GFX_WHITE);
    header(fb, "TOUCH NOISE, PEAK-TO-PEAK COUNTS");
    gfx_text(fb, 4, 24, "CASE        E0 E1 E2 E3 E4 E5 E6 E7 E8", INK, GFX_WHITE, 1);
    for (unsigned i = 0; i < t->count && i < BU_NOISE_CASES; ++i) {
        const noise_case_t *c = &t->cases[i];
        char line[48];
        int n = snprintf(line, sizeof(line), "%-11.11s", c->label);
        for (int e = 0; e < 9 && n < (int)sizeof(line) - 3; ++e)
            n += c->skipped ? snprintf(line + n, sizeof(line) - n, "  -")
                            : snprintf(line + n, sizeof(line) - n, "%3u", c->pp[e]);
        uint16_t bg = (int)i == t->chosen ? GFX_RGB(200, 235, 200) : GFX_WHITE;
        gfx_fill(fb, 0, 42 + 18 * (int)i, GFX_W, 18, bg);
        gfx_text(fb, 4, 43 + 18 * (int)i, line, INK, bg, 1);
    }
    char line[48];
    int y = 42 + 18 * BU_NOISE_CASES + 6;
    if (t->chosen >= 0) {
        snprintf(line, sizeof(line), "Quietest PWM: %u Hz", (unsigned)t->cases[t->chosen].pwm_hz);
        gfx_text(fb, 4, y, line, INK, GFX_WHITE, 1);
    }
    int n = snprintf(line, sizeof(line), "Touch th:");
    for (int e = 0; e < 9 && n < (int)sizeof(line) - 3; ++e) n += snprintf(line + n, sizeof(line) - n, "%3u", t->touch[e]);
    gfx_text(fb, 4, y + 18, line, INK, GFX_WHITE, 1);
    prompt_area(fb, prompt, PANEL);
}

void bu_render_wheel(uint16_t *fb, const bu_wheel_view_t *w, const char *prompt)
{
    static const float deg[9] = {0, 90, 45, 0, -45, -90, -135, 180, 135};
    const int cx = 160, cy = 136;
    gfx_fill(fb, 0, 0, GFX_W, GFX_H, GFX_WHITE);
    header(fb, "WHEEL: RAW DELTA AND POSITION");
    gfx_ring(fb, cx, cy, 104, 2, GFX_GREY);
    for (int e = 0; e < 9; ++e) {
        int x = cx, y = cy;
        if (e) {
            x = cx + (int)lroundf(78.0f * cosf(deg[e] * 3.14159265f / 180.0f));
            y = cy - (int)lroundf(78.0f * sinf(deg[e] * 3.14159265f / 180.0f));
        }
        bool on = (w->touched >> e) & 1, seen = (w->seen >> e) & 1;
        uint16_t bg = on ? PASS_C : seen ? GFX_RGB(170, 215, 170) : PANEL;
        gfx_fill(fb, x - 26, y - 17, 52, 34, bg);
        char label[8];
        snprintf(label, sizeof(label), "E%d", e);
        gfx_text(fb, x - 8, y - 16, label, INK, bg, 1);
        snprintf(label, sizeof(label), "%d", w->delta[e]);
        gfx_text(fb, x - 4 * (int)strlen(label), y, label, INK, bg, 1);
    }
    if (w->has_angle) {
        int x = cx + (int)lroundf(103.0f * cosf(w->angle_deg * 3.14159265f / 180.0f));
        int y = cy - (int)lroundf(103.0f * sinf(w->angle_deg * 3.14159265f / 180.0f));
        gfx_disc(fb, x, y, 7, FAIL_C);
    }
    char line[48];
    snprintf(line, sizeof(line), "Angle %4.0f  zone %-8s steps %ld", w->has_angle ? w->angle_deg : 0.0f,
             w->zone ? w->zone : "-", w->steps);
    gfx_text(fb, 4, 244, line, INK, GFX_WHITE, 1);
    prompt_area(fb, prompt, PANEL);
    snprintf(line, sizeof(line), "Turn %4.0f/300 %s  centre tap %s", w->turn_deg, w->turn_done ? "ok" : "--",
             w->centre_tap ? "ok" : "--");
    gfx_text(fb, 4, PROMPT_Y + 36, line, INK, PANEL, 1);
}
