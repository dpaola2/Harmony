/* Power-side pure logic: back-power-safe 3V3_PERIPH sequence (GPIO mocks),
 * VSYS backlight compensation, battery and divider parsing, board identity. */
#include <assert.h>
#include <stdio.h>
#include <string.h>
#include "slab_pins.h"
#include "slab_power_seq.h"
#include "slab_backlight.h"
#include "slab_analog.h"
#include "slab_board.h"
#include "max17048.h"

/* ------------------------------------------------------------ GPIO mock */
enum { UNSET, OUT, IN };
static int mode[40], level[40];
static unsigned waited_since_on, calls, fail_at;
static bool rail_on;
static bool is_line(int g)
{
    for (unsigned i = 0; i < slab_periph_line_count; ++i) if (slab_periph_lines[i].gpio == g) return true;
    return false;
}
static void check_safe_for_switch(void)
{
    for (unsigned i = 0; i < slab_periph_line_count; ++i) {
        int g = slab_periph_lines[i].gpio;
        assert(mode[g] == IN || (mode[g] == OUT && level[g] == 0));
    }
}
static int m_output(int g, int l)
{
    if (++calls == fail_at) return 1;
    assert(g < 34);                                   /* GPIO34 to 39 are input only */
    if (g == SLAB_PIN_PERIPH_EN_N) {
        bool on = l == 0;
        if (on != rail_on) check_safe_for_switch();   /* SPEC 5.3: lines low or input at the switch */
        rail_on = on;
        if (on) waited_since_on = 0;
    } else if (is_line(g) && l) {
        /* Never drive a screen or card line high into the unpowered rail. */
        assert(rail_on);
        assert(g == SLAB_PIN_SD_CS && waited_since_on >= SLAB_PERIPH_RAMP_MS);
    }
    if (g == SLAB_PIN_LCD_CS) assert(l == 0);         /* touch rule 1: CS only ever low */
    mode[g] = OUT; level[g] = l;
    return 0;
}
static int m_input(int g) { if (++calls == fail_at) return 1; mode[g] = IN; return 0; }
static void m_delay(unsigned ms) { waited_since_on += ms; }
static const slab_gpio_ops_t ops = {m_output, m_input, m_delay};

static void reset_mock(void) { memset(mode, 0, sizeof(mode)); memset(level, 0, sizeof(level)); calls = fail_at = 0; }

static void test_sequence(void)
{
    /* Reset state: Q4 held off by R13, lines floating; the boot order must still be safe. */
    reset_mock(); rail_on = false;
    level[SLAB_PIN_SD_CS] = 1;                        /* a stale level from before a reset */
    assert(slab_periph_off(&ops) == 0);
    assert(mode[SLAB_PIN_PERIPH_EN_N] == OUT && level[SLAB_PIN_PERIPH_EN_N] == 1 && !rail_on);
    assert(mode[SLAB_PIN_LCD_BL] == OUT && level[SLAB_PIN_LCD_BL] == 0);
    assert(slab_periph_on(&ops) == 0 && rail_on);
    assert(level[SLAB_PIN_LCD_CS] == 0 && mode[SLAB_PIN_LCD_CS] == OUT);
    assert(level[SLAB_PIN_SD_CS] == 1 && mode[SLAB_PIN_SD_CS] == OUT);
    assert(mode[SLAB_PIN_SD_MISO] == IN && mode[SLAB_PIN_LCD_TE] == IN);
    /* Running state: the SPI peripherals released the pins high; off must bring them down first. */
    for (unsigned i = 0; i < slab_periph_line_count; ++i)
        if (!slab_periph_lines[i].input) { mode[slab_periph_lines[i].gpio] = OUT; level[slab_periph_lines[i].gpio] = 1; }
    level[SLAB_PIN_LCD_CS] = 0;
    level[SLAB_PIN_LCD_BL] = 1;
    assert(slab_periph_off(&ops) == 0 && !rail_on);
    assert(level[SLAB_PIN_LCD_BL] == 0);
    for (unsigned i = 0; i < slab_periph_line_count; ++i) {
        int g = slab_periph_lines[i].gpio;
        assert(slab_periph_lines[i].input ? mode[g] == IN : level[g] == 0);
    }
    /* Any failing step stops before the switch moves. */
    for (unsigned f = 1; f <= slab_periph_line_count + 1; ++f) {
        reset_mock(); rail_on = true; mode[SLAB_PIN_PERIPH_EN_N] = OUT; level[SLAB_PIN_PERIPH_EN_N] = 0;
        fail_at = f;
        assert(slab_periph_off(&ops) != 0 && rail_on);
        reset_mock(); rail_on = false; fail_at = f;
        assert(slab_periph_on(&ops) != 0 && !rail_on);
    }
    /* Every screen and card net from the pin map is in the list. */
    const int expect[] = {SLAB_PIN_LCD_SCK, SLAB_PIN_LCD_MOSI, SLAB_PIN_LCD_CS, SLAB_PIN_LCD_DC, SLAB_PIN_LCD_RST,
        SLAB_PIN_LCD_TE, SLAB_PIN_SD_SCK, SLAB_PIN_SD_MOSI, SLAB_PIN_SD_MISO, SLAB_PIN_SD_CS};
    for (unsigned i = 0; i < sizeof(expect) / sizeof(expect[0]); ++i) assert(is_line(expect[i]));
    assert(slab_periph_line_count == 10);
    puts("PASS 3V3_PERIPH sequence: lines low or input before every switch, nothing high into the dead rail, CS only low, ramp wait, failures stop early");
}

static void test_backlight(void)
{
    /* README Power note 3: about 120 mA at 4.2 V and about 170 mA at VSYS 4.7 V, full duty. */
    unsigned bat = slab_bl_full_ma(4200), usb = slab_bl_full_ma(4700);
    assert(bat >= 115 && bat <= 125 && usb >= 160 && usb <= 175);
    assert(slab_bl_full_ma(2800) == 0 && slab_bl_full_ma(2000) == 0);
    slab_bl_plan_t p = slab_bl_plan(100, 3700, false);
    assert(p.duty_permille >= 995 && !p.limited);
    p = slab_bl_plan(80, 4200, false);
    assert(p.duty_permille > 500 && p.duty_permille < 525 && p.avg_ma >= 61 && p.avg_ma <= 64);
    /* Same brightness on battery and on USB: same average current, lower duty on USB. */
    slab_bl_plan_t b = slab_bl_plan(80, 3900, false), u = slab_bl_plan(80, 4650, true);
    assert(u.duty_permille < b.duty_permille && (int)u.avg_ma - (int)b.avg_ma <= 1 && (int)b.avg_ma - (int)u.avg_ma <= 1);
    /* Low cell: cannot reach the target, runs at full duty. */
    p = slab_bl_plan(100, 3400, false);
    assert(p.duty_permille == 1000 && p.limited && p.avg_ma == slab_bl_full_ma(3400));
    /* USB cap (README: at or below 80 percent) and the R17 power cap at high VBUS. */
    p = slab_bl_plan(250, 4700, true);
    assert(p.duty_permille == SLAB_BL_USB_MAX_PERMILLE && p.limited);
    p = slab_bl_plan(250, 4900, true);
    assert(p.duty_permille < SLAB_BL_USB_MAX_PERMILLE && p.r17_mw <= SLAB_BL_P_MAX_MW + 1 && p.limited);
    assert(slab_bl_plan(0, 4200, false).duty_permille == 0);
    for (unsigned v = 2500; v <= 5400; v += 10)
        for (unsigned pct = 0; pct <= 250; pct += 5)
            for (int usbp = 0; usbp < 2; ++usbp) {
                slab_bl_plan_t q = slab_bl_plan(pct, v, usbp);
                assert(q.duty_permille <= 1000);
                if (usbp) assert(q.duty_permille <= SLAB_BL_USB_MAX_PERMILLE);
                assert(q.r17_mw <= SLAB_BL_P_MAX_MW + 1);
                if (pct && slab_bl_full_ma(v)) assert(q.duty_permille >= SLAB_BL_MIN_PERMILLE);
            }
    printf("BACKLIGHT full 4.2V=%u mA, full 4.7V=%u mA, 80%% at 3.9V duty=%u avg=%u mA, on USB 4.65V duty=%u avg=%u mA\n",
           bat, usb, b.duty_permille, b.avg_ma, u.duty_permille, u.avg_ma);
    puts("PASS VSYS backlight compensation: README currents, constant average current, USB 80 percent cap, R17 power cap");
}

static void test_battery(void)
{
    assert(max17048_vcell_mv(0xD200) == 4200);            /* 53760 x 78.125 uV */
    assert(max17048_vcell_mv(0xB800) == 3680);
    assert(max17048_vcell_mv(0) == 0 && max17048_vcell_mv(0xFFFF) == 5120);
    assert(max17048_percent(0x4E80) == 79 && max17048_percent(0x4E7F) == 78);
    assert(max17048_percent(0x0000) == 0 && max17048_percent(0x6400) == 100 && max17048_percent(0x6600) == 100);
    assert(max17048_crate(0x0005) == 1040 && max17048_crate(0xFFFB) == -1040);
    assert(max17048_version_ok(0x0011) && max17048_version_ok(0x0012) && !max17048_version_ok(0x0002) && !max17048_version_ok(0xFFFF));
    max17048_reading_t r;
    max17048_parse((uint8_t[]){0xC5, 0x00}, (uint8_t[]){0x3A, 0xC0}, (uint8_t[]){0xFF, 0xF6}, 0x0012, &r);
    assert(r.vcell_mv == 3940 && r.percent == 59 && r.soc_x256 == 0x3AC0 && r.crate_pct_x1000 == -2080 && r.version == 0x12);
    /* Dividers: VBAT 1M/1M, VBUS 100k/150k. */
    assert(slab_divider_mv(2000, SLAB_VBAT_DIVIDER_X1000) == 4000);
    assert(slab_divider_mv(3000, SLAB_VBUS_DIVIDER_X1000) == 5001);
    assert(slab_vbus_present(4300) && !slab_vbus_present(4299) && !slab_vbus_present(0));
    assert(slab_vsys_estimate_mv(0, 3900) == 3900);
    assert(slab_vsys_estimate_mv(5000, 4200) == 4650);
    assert(slab_vsys_estimate_mv(4400, 4200) == 4050);    /* weak USB: VBUS minus D1 still wins */
    puts("PASS battery: MAX17048 VCELL, SOC rounding and clamp, CRATE sign, version; dividers; VSYS estimate");
}

static void test_identity(void)
{
    const uint8_t mac[6] = {0xE8, 0x31, 0xCD, 0x12, 0x34, 0x56};
    assert(slab_mac_matches("", mac) && slab_mac_matches(NULL, mac));
    assert(slab_mac_matches("e8:31:cd:12:34:56", mac) && slab_mac_matches("E8:31:CD:12:34:56", mac));
    assert(!slab_mac_matches("e8:31:cd:12:34:57", mac) && !slab_mac_matches("e8:31:cd:12:34", mac));
    assert(!slab_mac_matches("e8:31:cd:12:34:56x", mac) && !slab_mac_matches("e8-31-cd-12-34-56", mac));
    puts("PASS board identity: blank accepts, exact MAC match, malformed rejected");
}

int main(void)
{
    test_sequence();
    test_backlight();
    test_battery();
    test_identity();
    return 0;
}
