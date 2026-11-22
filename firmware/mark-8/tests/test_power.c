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
    /* Revision A.2 Q4 network: 90 percent at 3.3 to 10.1 ms, so the wait is at least 10.1 ms plus margin. */
    assert(SLAB_PERIPH_RAMP_MS >= 20);
    /* Card power cycle (review CC-2): the rail drains for about 0.4 s before it may come back. */
    assert(SLAB_PERIPH_DRAIN_MS >= 400);
    assert(slab_periph_drain_wait_ms(true, 0) == 0);
    assert(slab_periph_drain_wait_ms(false, 0) == SLAB_PERIPH_DRAIN_MS);
    assert(slab_periph_drain_wait_ms(false, 120) == SLAB_PERIPH_DRAIN_MS - 120);
    assert(slab_periph_drain_wait_ms(false, SLAB_PERIPH_DRAIN_MS) == 0);
    assert(slab_periph_drain_wait_ms(false, 60000) == 0);
    puts("PASS 3V3_PERIPH sequence: lines low or input before every switch, nothing high into the dead rail, CS only low, 20 ms ramp wait, 0.5 s drain before the rail returns, failures stop early");
}

static void test_backlight(void)
{
    /* README Power note 3: about 120 mA at 4.2 V and about 170 mA at VSYS 4.7 V, full duty. */
    unsigned bat = slab_bl_full_ma(4200), usb = slab_bl_full_ma(4700);
    assert(bat >= 115 && bat <= 125 && usb >= 160 && usb <= 175);
    assert(slab_bl_full_ma(2800) == 0 && slab_bl_full_ma(2000) == 0);
    /* Worst case for the R17 cap (review PERIPH-2): VF 2.7 V, 10 ohm, about 224 mA at 4.95 V. */
    assert(slab_bl_worst_ma(4950) >= 224 && slab_bl_worst_ma(4950) <= 226);
    assert(slab_bl_worst_ma(2700) == 0);
    for (unsigned v = 2900; v <= 5400; v += 10) assert(slab_bl_worst_ma(v) >= slab_bl_full_ma(v));
    slab_bl_plan_t p = slab_bl_plan(100, 3700, false);
    assert(p.duty_permille >= 995 && !p.limited);
    p = slab_bl_plan(80, 4200, false);
    assert(p.duty_permille > 500 && p.duty_permille < 525 && p.avg_ma >= 61 && p.avg_ma <= 64);
    /* Same brightness on battery and on USB: same average current, lower duty on USB. */
    slab_bl_plan_t b = slab_bl_plan(80, 3900, false), u = slab_bl_plan(80, 4650, true);
    assert(u.duty_permille < b.duty_permille && (int)u.avg_ma - (int)b.avg_ma <= 1 && (int)b.avg_ma - (int)u.avg_ma <= 1);
    assert(!b.limited && !u.limited);
    /* Low cell: cannot reach the target, runs at full duty. */
    p = slab_bl_plan(100, 3400, false);
    assert(p.duty_permille == 1000 && p.limited && p.avg_ma == slab_bl_full_ma(3400));
    /* Brightness stops at 100 percent. */
    for (unsigned v = 3000; v <= 5400; v += 50) {
        slab_bl_plan_t a = slab_bl_plan(100, v, v > 4300), c = slab_bl_plan(250, v, v > 4300);
        assert(a.duty_permille == c.duty_permille && a.avg_ma == c.avg_ma);
    }
    /* The R17 power cap bites at high VSYS: a 5.25 V port through D1 with a 2.7 V panel. */
    p = slab_bl_plan(100, 4900, true);
    assert(p.limited && p.duty_permille <= 420 && p.r17_mw <= SLAB_BL_P_MAX_MW);
    /* The USB 80 percent cap bites when VSYS is low on USB. */
    p = slab_bl_plan(100, 3900, true);
    assert(p.limited && p.duty_permille == SLAB_BL_USB_MAX_PERMILLE);
    assert(slab_bl_plan(0, 4200, false).duty_permille == 0);
    for (unsigned v = 2500; v <= 5400; v += 10)
        for (unsigned pct = 0; pct <= 250; pct += 5)
            for (int usbp = 0; usbp < 2; ++usbp) {
                slab_bl_plan_t q = slab_bl_plan(pct, v, usbp);
                assert(q.duty_permille <= 1000);
                if (usbp) assert(q.duty_permille <= SLAB_BL_USB_MAX_PERMILLE);
                /* Worst-case R17 power, recomputed here from the panel's minimum VF. */
                unsigned long w = v > 2700 ? (v - 2700 + 9) / 10 : 0;
                assert(w * w * 10 / 1000 * q.duty_permille / 1000 <= SLAB_BL_P_MAX_MW);
                assert(q.r17_mw <= SLAB_BL_P_MAX_MW);
                if (pct && slab_bl_full_ma(v)) assert(q.duty_permille >= SLAB_BL_MIN_PERMILLE);
            }
    printf("BACKLIGHT full 4.2V=%u mA, full 4.7V=%u mA, 80%% at 3.9V duty=%u avg=%u mA, on USB 4.65V duty=%u avg=%u mA, "
           "100%% at 4.9V USB duty=%u (R17 %u mW worst case)\n",
           bat, usb, b.duty_permille, b.avg_ma, u.duty_permille, u.avg_ma,
           slab_bl_plan(100, 4900, true).duty_permille, slab_bl_plan(100, 4900, true).r17_mw);
    puts("PASS VSYS backlight compensation: README currents, constant average current, brightness at most 100 percent, USB 80 percent cap, R17 cap from VF 2.7 V and 10 ohm");
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
    /* Dividers: VBAT 1M/1M, VBUS 100k/75k (revision A.2): 5.0 V is 2.14 V and 5.25 V is 2.25 V at the pin. */
    assert(SLAB_VBUS_DIVIDER_X1000 == 2333);
    assert(slab_divider_mv(2000, SLAB_VBAT_DIVIDER_X1000) == 4000);
    assert(slab_divider_mv(2143, SLAB_VBUS_DIVIDER_X1000) == 5000);
    assert(slab_divider_mv(2250, SLAB_VBUS_DIVIDER_X1000) == 5249);
    assert(slab_divider_mv(1843, SLAB_VBUS_DIVIDER_X1000) >= SLAB_VBUS_PRESENT_MV);   /* README: 4.3 V is 1.84 V */
    assert(slab_divider_mv(1842, SLAB_VBUS_DIVIDER_X1000) < SLAB_VBUS_PRESENT_MV);
    assert(slab_vbus_present(4300) && !slab_vbus_present(4299) && !slab_vbus_present(0));
    assert(slab_vsys_estimate_mv(0, 3900) == 3900);
    assert(slab_vsys_estimate_mv(5000, 4200) == 4650);
    assert(slab_vsys_estimate_mv(4400, 4200) == 4050);    /* weak USB: VBUS minus D1 still wins */
    /* Low-battery cutoff (review PWR-6): 5 readings in a row at or below 3.45 V on battery. */
    slab_bat_guard_t g = {0};
    for (int i = 0; i < SLAB_BAT_CUTOFF_POLLS - 1; ++i) assert(slab_bat_guard_poll(&g, 3450, false) == SLAB_BAT_OK);
    assert(slab_bat_guard_poll(&g, 3451, false) == SLAB_BAT_OK);           /* one good reading restarts the count */
    for (int i = 0; i < SLAB_BAT_CUTOFF_POLLS - 1; ++i) assert(slab_bat_guard_poll(&g, 3300, false) == SLAB_BAT_OK);
    assert(slab_bat_guard_poll(&g, 3300, false) == SLAB_BAT_EMPTY);
    assert(slab_bat_guard_poll(&g, 3300, false) == SLAB_BAT_EMPTY);        /* stays tripped while low */
    memset(&g, 0, sizeof(g));
    for (int i = 0; i < 100; ++i) assert(slab_bat_guard_poll(&g, 3300, true) == SLAB_BAT_OK);   /* never on USB */
    /* Reversed pack on USB (review PWR-2): VBAT_SENSE under 2 V for 10 s. */
    memset(&g, 0, sizeof(g));
    for (int i = 0; i < SLAB_BAT_REVERSED_POLLS - 1; ++i) assert(slab_bat_guard_poll(&g, 0, true) == SLAB_BAT_OK);
    assert(slab_bat_guard_poll(&g, 0, true) == SLAB_BAT_REVERSED);
    assert(slab_bat_guard_poll(&g, 4100, true) == SLAB_BAT_OK);
    assert(slab_bat_wake_allowed(3500, false) && !slab_bat_wake_allowed(3499, false) && slab_bat_wake_allowed(3000, true));
    puts("PASS battery: MAX17048 VCELL, SOC rounding and clamp, CRATE sign, version; dividers (VBUS 100k/75k); VSYS estimate; "
         "3.45 V cutoff after 5 s on battery only; 3.5 V wake floor without USB; reversed-pack notice on USB");
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
