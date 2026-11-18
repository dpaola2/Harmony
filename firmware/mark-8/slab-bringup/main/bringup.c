/* Harmony Mark-8 slab revision A: board bring-up test (SPEC 9).
 *
 * One PASS or FAIL line per block on the serial console ("BRINGUP <block>
 * <PASS|FAIL|SKIP> <detail>") and the same list on the screen. Order: power
 * and I2C first, then the screen, then the card, then the tests that need a
 * person (side button, buzzer, wheel), then two deep sleeps: wake on the side
 * button, then wake on a wheel touch. Results survive the sleeps in RTC
 * memory; the third boot prints the summary. */
#include <dirent.h>
#include <inttypes.h>
#include <math.h>
#include <stdarg.h>
#include <stdio.h>
#include <string.h>
#include <sys/stat.h>
#include <sys/time.h>
#include "sdkconfig.h"
#include "bringup_ui.h"
#include "gfx.h"
#include "noise_stats.h"
#include "slab_board.h"
#include "slab_i2c.h"
#include "slab_analog.h"
#include "slab_backlight.h"
#include "slab_buzzer.h"
#include "slab_cal.h"
#include "max17048.h"
#include "drv2605.h"
#include "mpr121.h"
#include "wheel.h"
#include "slab_wheel.h"
#include "st7365p.h"
#include "slab_dirty.h"
#include "bench_storage.h"
#include "driver/gpio.h"
#include "driver/uart.h"
#include "esp_adc/adc_oneshot.h"
#include "esp_adc/adc_cali.h"
#include "esp_adc/adc_cali_scheme.h"
#include "esp_app_desc.h"
#include "esp_attr.h"
#include "esp_heap_caps.h"
#include "esp_log.h"
#include "esp_sleep.h"
#include "esp_system.h"
#include "esp_timer.h"
#include "nvs_flash.h"
#include "sdmmc_cmd.h"
#include "freertos/FreeRTOS.h"
#include "freertos/semphr.h"
#include "freertos/task.h"

#ifndef CONFIG_SLAB_SLEEP_TOUCH_ESI_MS
#define CONFIG_SLAB_SLEEP_TOUCH_ESI_MS 64
#endif
#define MAGIC 0x534C4142u
#define NOISE_INTERVAL_MS 208   /* (2 x SFI 6 + 1) x ESI 16 ms: a read never sees a measurement it disturbed */
#define RAW_READ_BYTES (4u * 1024 * 1024)
#define CHUNK_SECTORS 32

RTC_DATA_ATTR static struct {
    uint32_t magic;
    uint8_t stage;               /* 0 run, 1 asleep for the button wake, 2 asleep for the touch wake */
    int64_t sleep_us;
    bu_result_t r[BU_COUNT];
    bu_noise_table_t noise;
} rtc;

static uint16_t *fb, *shadow;
static bool screen_ok, card_ok;
static const char *prompt = "Bring-up running. Results also on serial at 115200.";
static uint32_t now_ms(void) { return (uint32_t)(esp_timer_get_time() / 1000); }
static void sleep_ms(unsigned ms) { vTaskDelay(pdMS_TO_TICKS(ms ? ms : 1)); }

/* ---------------------------------------------------------------- screen */
static void flush(void)
{
    if (!screen_ok) return;
    slab_rect_t rects[24];
    unsigned n = slab_dirty_rects(shadow, fb, GFX_W, GFX_H, 8, rects, 24);
    for (unsigned i = 0; i < n; ++i) {
        const slab_rect_t *r = &rects[i];
        if (st7365p_blit(r->x, r->y, r->w, r->h, fb + (size_t)r->y * GFX_W + r->x, GFX_W) != ESP_OK) return;
        slab_rect_copy(shadow, fb, GFX_W, r);
    }
}

static void forget_screen_contents(void) { if (shadow) memset(shadow, 0x5A, (size_t)GFX_W * GFX_H * 2); }

static void show_results(const char *p)
{
    if (p) prompt = p;
    if (!screen_ok) return;
    bu_render_results(fb, rtc.r, prompt);
    flush();
}

static void result(int id, uint8_t status, const char *fmt, ...)
{
    va_list ap;
    va_start(ap, fmt);
    vsnprintf(rtc.r[id].detail, sizeof(rtc.r[id].detail), fmt, ap);
    va_end(ap);
    rtc.r[id].status = status;
    printf("BRINGUP %-8s %s %s\n", bu_names[id], bu_status_text(status), rtc.r[id].detail);
    show_results(NULL);
}

/* ---------------------------------------------------------------- side button */
static bool button_down(void) { return gpio_get_level(SLAB_PIN_SIDE_BTN) == 0; }

/* Waits for a press and release. Returns the press length in ms, or -1. */
static int wait_press(unsigned timeout_ms)
{
    uint32_t start = now_ms();
    while (button_down() && now_ms() - start < 3000) sleep_ms(10);   /* let go first */
    while (now_ms() - start < timeout_ms) {
        if (button_down()) {
            sleep_ms(30);
            if (!button_down()) continue;
            uint32_t t0 = now_ms() - 30;
            while (button_down() && now_ms() - t0 < 10000) sleep_ms(10);
            sleep_ms(30);
            return (int)(now_ms() - t0);
        }
        sleep_ms(10);
    }
    return -1;
}

/* ---------------------------------------------------------------- 3V3_PERIPH through the SD_CS pull-up */
static int periph_rail_mv(void)
{
    adc_oneshot_unit_handle_t unit;
    adc_cali_handle_t cali = NULL;
    adc_oneshot_unit_init_cfg_t u = {.unit_id = ADC_UNIT_2};
    adc_oneshot_chan_cfg_t ch = {.atten = ADC_ATTEN_DB_12, .bitwidth = ADC_BITWIDTH_DEFAULT};
    if (adc_oneshot_new_unit(&u, &unit) != ESP_OK) return -1;
    int mv = -1;
    adc_cali_line_fitting_config_t cal = {.unit_id = ADC_UNIT_2, .atten = ADC_ATTEN_DB_12,
        .bitwidth = ADC_BITWIDTH_DEFAULT, .default_vref = 1100};
    if (adc_oneshot_config_channel(unit, ADC_CHANNEL_8, &ch) == ESP_OK &&   /* GPIO25 = SD_CS */
        adc_cali_create_scheme_line_fitting(&cal, &cali) == ESP_OK) {
        int sum = 0, n = 0;
        for (int i = 0; i < 8; ++i) {
            int raw, v;
            if (adc_oneshot_read(unit, ADC_CHANNEL_8, &raw) == ESP_OK && adc_cali_raw_to_voltage(cali, raw, &v) == ESP_OK) { sum += v; ++n; }
        }
        if (n) mv = sum / n;
    }
    if (cali) adc_cali_delete_scheme_line_fitting(cali);
    adc_oneshot_del_unit(unit);
    return mv;
}

/* ---------------------------------------------------------------- blocks */
static void test_vbus(void)
{
    slab_analog_init();
    int vbus = slab_analog_vbus_mv();
    if (vbus < 0) { result(BU_VBUS, BU_FAIL, "ADC1 unavailable"); return; }
    bool present = slab_vbus_present((unsigned)vbus);
    result(BU_VBUS, present ? BU_PASS : BU_FAIL, "%d.%02d V on VBUS_SENSE (%s)", vbus / 1000, vbus % 1000 / 10,
           present ? "USB present" : "no USB: plug USB for the bring-up");
}

static void test_i2c(void)
{
    if (slab_i2c_init() != ESP_OK) { result(BU_I2C, BU_FAIL, "bus init failed"); return; }
    char found[96] = "";
    int n = 0, len = 0;
    bool need[3] = {false, false, false};
    for (uint8_t a = 0x08; a < 0x78; ++a) {
        if (!slab_i2c_probe(a)) continue;
        ++n;
        const char *name = a == SLAB_I2C_ADDR_MAX17048 ? " MAX17048" : a == SLAB_I2C_ADDR_DRV2605L ? " DRV2605L" :
                           a == SLAB_I2C_ADDR_MPR121 ? " MPR121" : " unknown";
        need[0] |= a == SLAB_I2C_ADDR_MAX17048; need[1] |= a == SLAB_I2C_ADDR_DRV2605L; need[2] |= a == SLAB_I2C_ADDR_MPR121;
        if (len < (int)sizeof(found) - 16) len += snprintf(found + len, sizeof(found) - len, "%s0x%02X%s", n > 1 ? ", " : "", a, name);
    }
    bool ok = need[0] && need[1] && need[2];
    result(BU_I2C, ok ? BU_PASS : BU_FAIL, "%s%s (%u kHz)", n ? found : "nothing answers",
           ok ? "" : "; missing a part", (unsigned)(slab_i2c_hz() / 1000));
}

static void test_battery(void)
{
    int divider = slab_analog_vbat_mv();
    max17048_reading_t g;
    esp_err_t err = max17048_read(&g);
    max17048_hibernate(false);
    if (err != ESP_OK) { result(BU_BATTERY, BU_FAIL, "MAX17048 read: %s; divider %d mV", esp_err_to_name(err), divider); return; }
    int diff = divider - (int)g.vcell_mv;
    bool ok = divider > 2500 && divider < 4400 && diff > -150 && diff < 150;
    result(BU_BATTERY, ok ? BU_PASS : BU_FAIL, "divider %d.%02d V, gauge %u.%02u V, %u %%, v0x%04X",
           divider / 1000, divider % 1000 / 10, g.vcell_mv / 1000, g.vcell_mv % 1000 / 10, g.percent, g.version);
}

static void test_haptic(void)
{
    unsigned id = 0;
    if (!drv2605_detect(&id)) { result(BU_HAPTIC, BU_FAIL, "no DRV2605L (id %u)", id); return; }
    esp_err_t err = drv2605_setup_erm();
#if CONFIG_SLAB_MOTOR_FITTED
    if (err == ESP_OK) err = drv2605_play(DRV2605_EFFECT_STRONG_CLICK);
    result(BU_HAPTIC, err == ESP_OK ? BU_PASS : BU_FAIL, "DRV2605L id %u, ERM setup %s, buzz sent", id, esp_err_to_name(err));
#else
    result(BU_HAPTIC, err == ESP_OK ? BU_PASS : BU_FAIL, "DRV2605L id %u, setup %s; no motor (config)", id, esp_err_to_name(err));
#endif
}

static mpr121_settings_t touch_settings;
/* Config thresholds, or the ones the noise table chose (kept in RTC memory). */
static esp_err_t start_touch(void)
{
    mpr121_default_settings(&touch_settings, CONFIG_SLAB_TOUCH_THRESHOLD, CONFIG_SLAB_RELEASE_THRESHOLD);
#if CONFIG_SLAB_TOUCH_SLOW_FALLING_BASELINE
    touch_settings.slow_falling_baseline = true;
#endif
    if (rtc.noise.touch[0]) {
        memcpy(touch_settings.touch, rtc.noise.touch, 9);
        memcpy(touch_settings.release, rtc.noise.release, 9);
    }
    return mpr121_start(&touch_settings);
}

static void test_touch(void)
{
    mpr121_reg_t table[48];
    esp_err_t err = start_touch();
    size_t regs = mpr121_config_table(&touch_settings, table, 48);
    mpr121_frame_t f = {0};
    if (err == ESP_OK) { sleep_ms(300); err = mpr121_read_frame(&f); }
    if (err != ESP_OK) { result(BU_TOUCH, BU_FAIL, "MPR121 start: %s", esp_err_to_name(err)); return; }
    printf("TOUCH data:");
    for (int i = 0; i < 9; ++i) printf(" E%d=%u/%u", i, f.filtered[i], f.baseline[i]);
    printf(" oor=0x%04x touched=0x%03x\n", f.oor, f.touched);
    bool ok = !(f.oor & 0x81FF) && !f.touched && !f.overcurrent;
    result(BU_TOUCH, ok ? BU_PASS : BU_FAIL, "%u regs verified, autoconfig %s, %s", (unsigned)regs,
           (f.oor & 0x8000) ? "FAILED" : "ok", f.touched ? "touched at start: hands off" :
           (f.oor & 0x1FF) ? "electrode out of range" : "untouched");
}

static void plain_output(int gpio, int level)
{
    gpio_set_level(gpio, level);
    gpio_config_t c = {.pin_bit_mask = 1ULL << gpio, .mode = GPIO_MODE_OUTPUT, .pull_up_en = GPIO_PULLUP_DISABLE,
        .pull_down_en = GPIO_PULLDOWN_DISABLE, .intr_type = GPIO_INTR_DISABLE};
    gpio_config(&c);   /* also takes the pad back from the RTC mux the ADC used */
    gpio_set_level(gpio, level);
}

static void test_periph(void)
{
    /* The board init left Q4 off with SD_CS driven low, which drains the rail through R22.
     * The ADC then reads the rail through R22 with the pad high-impedance. */
    sleep_ms(800);
    int off = periph_rail_mv();
    plain_output(SLAB_PIN_SD_CS, 0);
    esp_err_t err = slab_board_periph_power(true);
    sleep_ms(10);
    int on = periph_rail_mv();
    plain_output(SLAB_PIN_SD_CS, 1);
    bool ok = err == ESP_OK && off >= 0 && off < 400 && on > 2800;
    result(BU_PERIPH, ok ? BU_PASS : BU_FAIL, "3V3_PERIPH off %d mV, on %d mV (SD_CS pull-up)", off, on);
}

static void start_screen(void)
{
    st7365p_config_t cfg;
    st7365p_default_config(&cfg);
    fb = heap_caps_calloc((size_t)GFX_W * GFX_H, 2, MALLOC_CAP_SPIRAM);
    shadow = heap_caps_calloc((size_t)GFX_W * GFX_H, 2, MALLOC_CAP_SPIRAM);
    esp_err_t err = fb && shadow ? st7365p_init(&cfg) : ESP_ERR_NO_MEM;
    screen_ok = err == ESP_OK;
    slab_backlight_init(CONFIG_SLAB_BL_FALLBACK_HZ);
    if (!screen_ok) { result(BU_SCREEN, BU_FAIL, "ST7365P init: %s", esp_err_to_name(err)); return; }
    bu_render_bars(fb, "Screen test. Check the arrow and colours; the side button test follows.");
    flush();
    slab_backlight_set_permille(600);
    printf("BRINGUP screen: ST7365P %u Hz, MADCTL 0x%02X, bars and TOP arrow drawn (%" PRIu32 " bytes so far)\n",
           (unsigned)cfg.clock_hz, cfg.madctl, st7365p_bytes_sent());
    sleep_ms(3000);
}

static int largest_file(const char *dir, int depth, char *best, size_t best_size, long *best_len, int *budget)
{
    DIR *d = opendir(dir);
    if (!d) return 0;
    struct dirent *e;
    while ((e = readdir(d)) && --*budget > 0) {
        if (e->d_name[0] == '.') continue;
        char path[300];
        if (snprintf(path, sizeof(path), "%s/%s", dir, e->d_name) >= (int)sizeof(path)) continue;
        struct stat st;
        if (stat(path, &st)) continue;
        if (S_ISDIR(st.st_mode) && depth > 0) largest_file(path, depth - 1, best, best_size, best_len, budget);
        else if (S_ISREG(st.st_mode) && st.st_size > *best_len) { *best_len = st.st_size; snprintf(best, best_size, "%s", path); }
        if (*best_len >= (long)RAW_READ_BYTES) break;
    }
    closedir(d);
    return 0;
}

static void test_card(void)
{
    gpio_set_direction(SLAB_PIN_SD_CD, GPIO_MODE_INPUT);
    if (gpio_get_level(SLAB_PIN_SD_CD) != 0) { result(BU_CARD, BU_FAIL, "no card: SD_CD high (insert a card)"); return; }
    esp_err_t err = bench_storage_mount();
    sdmmc_card_t *card = bench_storage_card();
    if (err != ESP_OK || !card) { result(BU_CARD, BU_FAIL, "card detected, mount failed: %s", esp_err_to_name(err)); return; }
    uint8_t *buf = heap_caps_malloc(CHUNK_SECTORS * 512, MALLOC_CAP_DMA);
    if (!buf) { result(BU_CARD, BU_FAIL, "no DMA buffer"); return; }
    unsigned errors = 0;
    int64_t t0 = esp_timer_get_time();
    for (unsigned s = 0; s < RAW_READ_BYTES / 512; s += CHUNK_SECTORS)
        if (sdmmc_read_sectors(card, buf, s, CHUNK_SECTORS) != ESP_OK) ++errors;
    int64_t raw_us = esp_timer_get_time() - t0;
    unsigned raw_kbs = (unsigned)((uint64_t)RAW_READ_BYTES * 1000000 / 1024 / (raw_us ? raw_us : 1));
    char path[300] = "";
    long len = 0;
    int budget = 400;
    largest_file("/sd", 3, path, sizeof(path), &len, &budget);
    unsigned file_kbs = 0;
    long got = 0;
    if (len > 0) {
        FILE *f = fopen(path, "rb");
        if (f) {
            t0 = esp_timer_get_time();
            size_t n;
            while (got < (long)RAW_READ_BYTES && (n = fread(buf, 1, CHUNK_SECTORS * 512, f)) > 0) got += (long)n;
            int64_t us = esp_timer_get_time() - t0;
            if (ferror(f)) ++errors;
            fclose(f);
            file_kbs = (unsigned)((uint64_t)got * 1000000 / 1024 / (us ? us : 1));
        }
    }
    heap_caps_free(buf);
    uint64_t mb = (uint64_t)card->csd.capacity * card->csd.sector_size / (1024 * 1024);
    printf("CARD %s, %" PRIu64 " MB; raw %u KB/s over 4 MB; file %s %ld bytes at %u KB/s; errors %u\n",
           card->ocr & (1u << 30) ? "SDHC/SDXC" : "SDSC", mb, raw_kbs, path[0] ? path : "(none)", got, file_kbs, errors);
    card_ok = errors == 0;
    result(BU_CARD, errors == 0 && raw_kbs >= 500 ? BU_PASS : BU_FAIL, "%u MB, %d MHz, raw %u KB/s, file %u KB/s, %u err",
           (unsigned)mb, CONFIG_SLAB_SD_SPI_KHZ / 1000, raw_kbs, file_kbs, errors);
}

/* ---------------------------------------------------------------- noise table */
static volatile uint32_t noise_irqs;
static void IRAM_ATTR count_irq(void *arg) { (void)arg; ++noise_irqs; }
static volatile bool activity_stop;
static SemaphoreHandle_t activity_done;
enum { ACT_NONE, ACT_SCREEN, ACT_CARD, ACT_BUZZER };

static void activity_task(void *arg)
{
    int kind = (int)(intptr_t)arg;
    uint16_t c = GFX_BLACK;
    uint8_t *buf = kind == ACT_CARD ? heap_caps_malloc(CHUNK_SECTORS * 512, MALLOC_CAP_DMA) : NULL;
    unsigned sector = 0;
    while (!activity_stop) {
        if (kind == ACT_SCREEN) { st7365p_fill(0, 22, GFX_W, 240, c); c ^= 0xFFFF; }
        else if (kind == ACT_CARD && buf && bench_storage_card()) {
            sdmmc_read_sectors(bench_storage_card(), buf, sector, CHUNK_SECTORS);
            sector = (sector + CHUNK_SECTORS) % (RAW_READ_BYTES / 512);
        } else sleep_ms(20);
    }
    heap_caps_free(buf);
    xSemaphoreGive(activity_done);
    vTaskDelete(NULL);
}

static void run_noise_case(noise_case_t *c, int activity)
{
    if (activity == ACT_CARD && !card_ok) { c->skipped = true; return; }
    if (activity == ACT_SCREEN && !screen_ok) { c->skipped = true; return; }
    slab_backlight_set_freq(c->pwm_hz ? c->pwm_hz : CONFIG_SLAB_BL_FALLBACK_HZ);
    slab_backlight_set_permille(c->duty_permille);
    activity_stop = false;
    if (activity == ACT_BUZZER) slab_buzzer_tone(CONFIG_SLAB_CLICK_HZ, 25);
    else if (activity != ACT_NONE) xTaskCreatePinnedToCore(activity_task, "activity", 4096, (void *)(intptr_t)activity, 2, NULL, 1);
    sleep_ms(2 * NOISE_INTERVAL_MS);   /* let the touch filters settle */
    noise_acc_t acc;
    noise_reset(&acc);
    uint32_t irqs0 = noise_irqs;
    unsigned samples = CONFIG_SLAB_NOISE_SAMPLES;
    /* README Power note 3 keeps the duty at or below 80 percent on USB (R17 power). The
     * no-edges case needs 100 percent, so on USB it runs for about 3 s instead of 5. */
    int vbus = slab_analog_vbus_mv();
    if (c->duty_permille >= 1000 && vbus > 0 && slab_vbus_present((unsigned)vbus) && samples > 12) samples = 12;
    for (unsigned i = 0; i < samples; ++i) {
        sleep_ms(NOISE_INTERVAL_MS);
        mpr121_frame_t f;
        if (mpr121_read_frame(&f) == ESP_OK) noise_add(&acc, f.filtered);
    }
    c->irqs = (uint16_t)(noise_irqs - irqs0);
    if (activity == ACT_BUZZER) slab_buzzer_tone(0, 0);
    else if (activity != ACT_NONE) { activity_stop = true; xSemaphoreTake(activity_done, pdMS_TO_TICKS(3000)); }
    noise_finish(&acc, c);
    printf("NOISE %-11s", c->label);
    for (int e = 0; e < 9; ++e) printf(" E%d=%u", e, c->pp[e]);
    printf(" worst=%u irqs=%u samples=%u\n", c->worst, c->irqs, c->samples);
}

static void print_noise_table(const bu_noise_table_t *t)
{
    printf("NOISE case        E0  E1  E2  E3  E4  E5  E6  E7  E8  worst irqs\n");
    for (unsigned i = 0; i < t->count; ++i) {
        const noise_case_t *c = &t->cases[i];
        printf("NOISE %-11s", c->label);
        for (int e = 0; e < 9; ++e) { if (c->skipped) printf("   -"); else printf(" %3u", c->pp[e]); }
        printf("  %5u %4u%s\n", c->worst, c->irqs, (int)i == t->chosen ? "  <- quietest PWM" : "");
    }
    printf("NOISE touch thresholds:");
    for (int e = 0; e < 9; ++e) printf(" E%d=%u/%u", e, t->touch[e], t->release[e]);
    printf("\n");
}

static void test_noise(void)
{
    bu_noise_table_t *t = &rtc.noise;
    memset(t, 0, sizeof(*t));
    t->chosen = -1;
    static const struct { const char *label; uint32_t hz; uint16_t duty; bool pwm; } base[] = {
        {"BL off", 0, 0, false}, {"BL 100%", 0, 1000, false},
        {"50% 1kHz", 1000, 500, true}, {"50% 20kHz", 20000, 500, true}, {"50% 40kHz", 40000, 500, true}};
    activity_done = xSemaphoreCreateBinary();
    /* Count TOUCH_IRQ edges: with hands off, every edge is a false touch. */
    gpio_config_t irq = {.pin_bit_mask = 1ULL << SLAB_PIN_TOUCH_IRQ, .mode = GPIO_MODE_INPUT,
        .pull_up_en = GPIO_PULLUP_DISABLE, .pull_down_en = GPIO_PULLDOWN_DISABLE, .intr_type = GPIO_INTR_NEGEDGE};
    gpio_config(&irq);
    if (gpio_install_isr_service(0) == ESP_ERR_NO_MEM) { result(BU_NOISE, BU_FAIL, "no ISR service"); return; }
    gpio_isr_handler_add(SLAB_PIN_TOUCH_IRQ, count_irq, NULL);
    printf("NOISE reads every %u ms, %u samples per case; keep hands off the wheel\n", NOISE_INTERVAL_MS, CONFIG_SLAB_NOISE_SAMPLES);
    const char *hands_off = "NOISE: hands off the wheel for about 45 s.";
    for (unsigned i = 0; i < 5; ++i) {
        noise_case_t *c = &t->cases[t->count++];
        snprintf(c->label, sizeof(c->label), "%s", base[i].label);
        c->pwm_hz = base[i].hz; c->duty_permille = base[i].duty; c->pwm_case = base[i].pwm;
        if (screen_ok) { bu_render_noise(fb, t, hands_off); flush(); }
        run_noise_case(c, ACT_NONE);
    }
    t->chosen = noise_quietest(t->cases, t->count);
    uint32_t hz = t->chosen >= 0 ? t->cases[t->chosen].pwm_hz : CONFIG_SLAB_BL_FALLBACK_HZ;
    static const struct { const char *label; int act; } extra[] = {
        {"+screen", ACT_SCREEN}, {"+card read", ACT_CARD}, {"+buzzer", ACT_BUZZER}};
    for (unsigned i = 0; i < 3; ++i) {
        noise_case_t *c = &t->cases[t->count++];
        snprintf(c->label, sizeof(c->label), "%s", extra[i].label);
        c->pwm_hz = hz; c->duty_permille = 500; c->activity = true;
        if (screen_ok && extra[i].act != ACT_SCREEN) { bu_render_noise(fb, t, hands_off); flush(); }
        run_noise_case(c, extra[i].act);
        if (extra[i].act == ACT_SCREEN) forget_screen_contents();
    }
    gpio_isr_handler_remove(SLAB_PIN_TOUCH_IRQ);
    gpio_set_intr_type(SLAB_PIN_TOUCH_IRQ, GPIO_INTR_DISABLE);
    uint8_t worst[9];
    bool ok = noise_thresholds(t->cases, t->count, t->chosen, t->touch, t->release, worst);
    print_noise_table(t);
    slab_backlight_set_freq(hz);
    slab_backlight_set_permille(600);
    if (screen_ok) { bu_render_noise(fb, t, "Noise table done. Saved for the player."); flush(); sleep_ms(4000); }
    slab_cal_t cal = {.bl_pwm_hz = hz};
    memcpy(cal.touch, t->touch, 9); memcpy(cal.release, t->release, 9); memcpy(cal.worst_pp, worst, 9);
    esp_err_t saved = slab_cal_save(&cal);
    mpr121_set_thresholds(t->touch, t->release);
    unsigned tmin = 255, tmax = 0, wmax = 0;
    for (int e = 0; e < 9; ++e) {
        if (t->touch[e] < tmin) tmin = t->touch[e];
        if (t->touch[e] > tmax) tmax = t->touch[e];
        if (worst[e] > wmax) wmax = worst[e];
    }
    result(BU_NOISE, ok ? BU_PASS : BU_FAIL, "PWM %u Hz quietest, worst p-p %u, touch %u..%u%s",
           (unsigned)hz, wmax, tmin, tmax, saved == ESP_OK ? ", saved" : ", NOT saved");
}

/* ---------------------------------------------------------------- people tests */
static void test_button_and_screen(void)
{
    if (screen_ok) { bu_render_bars(fb, "BUTTON: press the side button once now."); forget_screen_contents(); flush(); }
    else show_results("BUTTON: press the side button once now.");
    printf("BRINGUP prompt: press the side button\n");
    int ms = wait_press(CONFIG_SLAB_PROMPT_SECONDS * 1000u);
    result(BU_BUTTON, ms > 0 ? BU_PASS : BU_FAIL, ms > 0 ? "pressed for %d ms" : "no press in %d s", ms > 0 ? ms : CONFIG_SLAB_PROMPT_SECONDS);
    if (!screen_ok) return;
    if (ms <= 0) { result(BU_SCREEN, BU_SKIP, "init ok; orientation not confirmed (no button)"); return; }
    bu_render_bars(fb, "Arrow at the top edge, bars RED GREEN BLUE WHITE? Press for yes; wait 15 s for no.");
    flush();
    printf("BRINGUP prompt: press the side button if the arrow points to the top edge and the colours read RED GREEN BLUE WHITE\n");
    int yes = wait_press(15000);
    result(BU_SCREEN, yes > 0 ? BU_PASS : BU_FAIL, yes > 0 ? "init ok at %d MHz, picture confirmed" :
           "init ok at %d MHz; NOT confirmed: see README", (int)(CONFIG_SLAB_LCD_SPI_HZ / 1000000));
}

static void test_buzzer(void)
{
    show_results("BUZZER: listen for 3 beeps, then press the side button if you heard them.");
    printf("BRINGUP prompt: press the side button if you hear 3 beeps\n");
    sleep_ms(1500);
    for (int i = 0; i < 3; ++i) { slab_buzzer_tone(CONFIG_SLAB_CLICK_HZ, 50); sleep_ms(150); slab_buzzer_tone(0, 0); sleep_ms(250); }
    if (rtc.r[BU_BUTTON].status != BU_PASS) { result(BU_BUZZER, BU_SKIP, "beeped; not confirmed (no button)"); return; }
    int yes = wait_press(15000);
    result(BU_BUZZER, yes > 0 ? BU_PASS : BU_FAIL, yes > 0 ? "3 beeps heard" : "no confirmation: beeps not heard?");
#if CONFIG_SLAB_MOTOR_FITTED
    show_results("HAPTIC: three buzzes now; press the side button if you felt them.");
    for (int i = 0; i < 3; ++i) { drv2605_play(DRV2605_EFFECT_STRONG_CLICK); sleep_ms(400); }
    int felt = wait_press(15000);
    result(BU_HAPTIC, felt > 0 ? BU_PASS : BU_FAIL, felt > 0 ? "DRV2605L and motor: buzz felt" : "motor buzz not confirmed");
#endif
}

static portMUX_TYPE view_lock = portMUX_INITIALIZER_UNLOCKED;
static bu_wheel_view_t view;

static void wheel_cb(const wheel_events_t *ev, const mpr121_frame_t *f, void *ctx)
{
    (void)ctx;
    wheel_state_t st = slab_wheel_state();
    float angle = 0;
    bool has = f && wheel_ring_angle(f->delta, 4, &angle);
    portENTER_CRITICAL(&view_lock);
    if (ev->touch_down) { view.turn_deg = 0; view.updates = 0; }
    if (f) {
        memcpy(view.delta, f->delta, sizeof(view.delta));
        view.touched = f->touched;
        view.seen |= f->touched & 0x1FF;
        for (int e = 0; e < 9; ++e) if ((f->touched >> e & 1) && f->delta[e] > view.peak[e]) view.peak[e] = f->delta[e];
        view.has_angle = has;
        if (has) { view.angle_deg = angle; view.zone = wheel_zone_name(wheel_zone_at(angle, CONFIG_SLAB_WHEEL_ZONE_HALF_DEG)); }
        ++view.updates;
    }
    view.steps += ev->steps;
    view.turn_deg = st.net_deg;
    bool turn_now = st.net_deg >= 300.0f && !view.turn_done;
    if (turn_now) view.turn_done = true;
    unsigned updates = view.updates;
    long steps_so_far = view.steps;
    if (ev->tap == WHEEL_ZONE_CENTRE) view.centre_tap = true;
    portEXIT_CRITICAL(&view_lock);
    /* No printf inside the critical section: newlib locks abort there. */
    if (turn_now) printf("WHEEL one clockwise turn: %u position updates, %ld steps so far\n", updates, steps_so_far);
    if (ev->steps) slab_buzzer_click(CONFIG_SLAB_CLICK_SCROLL_US);
    if (ev->tap != WHEEL_ZONE_NONE || ev->hold != WHEEL_ZONE_NONE) slab_buzzer_click(CONFIG_SLAB_CLICK_TAP_US);
    if (f) {
        printf("WHEEL t=%" PRIu32 " touched=0x%03x delta", now_ms(), f->touched);
        for (int e = 0; e < 9; ++e) printf(" %d", f->delta[e]);
        if (has) printf(" angle=%.0f", angle);
        printf(" steps=%d\n", ev->steps);
    }
    if (ev->tap != WHEEL_ZONE_NONE) printf("WHEEL tap %s\n", wheel_zone_name(ev->tap));
    if (ev->hold != WHEEL_ZONE_NONE) printf("WHEEL hold %s\n", wheel_zone_name(ev->hold));
}

static void wheel_config(wheel_config_t *c)
{
    wheel_default_config(c);
    c->step_deg = CONFIG_SLAB_WHEEL_STEP_DEG; c->start_deg = CONFIG_SLAB_WHEEL_START_DEG;
    c->tap_max_ms = CONFIG_SLAB_WHEEL_TAP_MAX_MS; c->tap_max_deg = CONFIG_SLAB_WHEEL_TAP_MAX_DEG;
    c->hold_ms = CONFIG_SLAB_WHEEL_HOLD_MS; c->zone_half_deg = CONFIG_SLAB_WHEEL_ZONE_HALF_DEG;
#if CONFIG_SLAB_WHEEL_REVERSE
    c->reverse = true;
#endif
}

static void test_wheel(void)
{
    if (rtc.r[BU_TOUCH].status != BU_PASS) { result(BU_WHEEL, BU_SKIP, "MPR121 did not start"); return; }
    memset(&view, 0, sizeof(view));
    memcpy(view.touch_th, rtc.noise.touch[0] ? rtc.noise.touch : touch_settings.touch, 9);
    wheel_config_t cfg;
    wheel_config(&cfg);
    if (slab_wheel_start(&cfg, wheel_cb, NULL, 6, 0) != ESP_OK) { result(BU_WHEEL, BU_FAIL, "wheel task did not start"); return; }
    const char *ask = "WHEEL: touch every sector, turn once clockwise, then tap the centre.";
    printf("BRINGUP prompt: touch every sector, turn the wheel once clockwise, then tap the centre (60 s)\n");
    uint32_t start = now_ms();
    bool done = false;
    while (!done && now_ms() - start < 60000) {
        bu_wheel_view_t v;
        portENTER_CRITICAL(&view_lock);
        v = view;
        portEXIT_CRITICAL(&view_lock);
        done = v.seen == 0x1FF && v.turn_done && v.centre_tap;
        if (screen_ok) { bu_render_wheel(fb, &v, ask); flush(); }
        sleep_ms(100);
    }
    sleep_ms(300);
    slab_wheel_stop();
    float margin = 1000;
    for (int e = 0; e < 9; ++e) {
        float m = view.touch_th[e] ? (float)view.peak[e] / view.touch_th[e] : 0;
        if ((view.seen >> e & 1) && m < margin) margin = m;
    }
    int seen = __builtin_popcount(view.seen);
    printf("WHEEL peak delta:");
    for (int e = 0; e < 9; ++e) printf(" E%d=%d/th%u", e, view.peak[e], view.touch_th[e]);
    printf(" IRQs=%" PRIu32 " reads=%" PRIu32 "\n", slab_wheel_irq_count(), slab_wheel_read_count());
    bool ok = done && margin >= 2.0f;
    result(BU_WHEEL, ok ? BU_PASS : BU_FAIL, "%d/9 seen, turn %s, centre tap %s, peak %.1fx threshold", seen,
           view.turn_done ? "ok" : "missing", view.centre_tap ? "ok" : "missing", seen ? margin : 0.0f);
}

/* ---------------------------------------------------------------- deep sleep */
static int64_t wall_us(void) { struct timeval tv; gettimeofday(&tv, NULL); return (int64_t)tv.tv_sec * 1000000 + tv.tv_usec; }

static void go_to_sleep(uint8_t stage)
{
    rtc.stage = stage;
    if (slab_wheel_running()) slab_wheel_stop();
    /* Stage 1 tests the side button with the MPR121 stopped; stage 2 keeps it scanning slowly. */
    esp_err_t err = mpr121_sleep(stage == 2, CONFIG_SLAB_SLEEP_TOUCH_ESI_MS);
    max17048_hibernate(true);
    drv2605_standby();
    slab_buzzer_tone(0, 0);
    if (screen_ok) { st7365p_sleep(); st7365p_deinit(); screen_ok = false; }
    bench_storage_unmount();
    slab_backlight_set_permille(0);
    slab_board_periph_power(false);
    slab_board_prepare_deep_sleep();
    esp_sleep_enable_timer_wakeup((uint64_t)CONFIG_SLAB_WAKE_TIMEOUT_S * 1000000);
    if (stage == 1) {
        uint32_t t0 = now_ms();
        while (button_down() && now_ms() - t0 < 10000) sleep_ms(10);
        if (button_down()) printf("BRINGUP side button still low after 10 s: no ext0 wake, the timer will record FAIL\n");
        else esp_sleep_enable_ext0_wakeup(SLAB_PIN_SIDE_BTN, 0);
        printf("BRINGUP sleeping: press the side button to wake (timeout %d s)\n", CONFIG_SLAB_WAKE_TIMEOUT_S);
    } else {
        uint32_t t0 = now_ms();
        while (gpio_get_level(SLAB_PIN_TOUCH_IRQ) == 0 && now_ms() - t0 < 5000) {
            uint8_t status[2];
            slab_i2c_read(SLAB_I2C_ADDR_MPR121, MPR121_REG_TOUCH_STATUS, status, 2);
            sleep_ms(100);
        }
        /* A stuck-low TOUCH_IRQ would wake at once and look like a pass. */
        if (gpio_get_level(SLAB_PIN_TOUCH_IRQ) == 0) printf("BRINGUP TOUCH_IRQ stuck low: no ext1 wake, the timer will record FAIL\n");
        else esp_sleep_enable_ext1_wakeup(1ULL << SLAB_PIN_TOUCH_IRQ, ESP_EXT1_WAKEUP_ALL_LOW);
        printf("BRINGUP sleeping: touch the wheel to wake (MPR121 scan %d ms: %s; timeout %d s)\n",
               CONFIG_SLAB_SLEEP_TOUCH_ESI_MS, esp_err_to_name(err), CONFIG_SLAB_WAKE_TIMEOUT_S);
    }
    fflush(stdout);
    uart_wait_tx_idle_polling(CONFIG_ESP_CONSOLE_UART_NUM);
    rtc.sleep_us = wall_us();
    esp_deep_sleep_start();
}

static void summary(void)
{
    unsigned pass = 0, fail = 0, skip = 0, total = 0;
    char failed[96] = "", skipped[64] = "";
    printf("BRINGUP ---- results ----\n");
    for (int i = 0; i < BU_COUNT; ++i) {
        const bu_result_t *r = &rtc.r[i];
        printf("BRINGUP %-8s %s %s\n", bu_names[i], bu_status_text(r->status), r->detail);
        if (r->status == BU_NOT_RUN) continue;
        ++total;
        if (r->status == BU_PASS) ++pass;
        else if (r->status == BU_FAIL) { ++fail; strncat(failed, " ", sizeof(failed) - strlen(failed) - 1); strncat(failed, bu_names[i], sizeof(failed) - strlen(failed) - 1); }
        else { ++skip; strncat(skipped, " ", sizeof(skipped) - strlen(skipped) - 1); strncat(skipped, bu_names[i], sizeof(skipped) - strlen(skipped) - 1); }
    }
    if (rtc.noise.count) print_noise_table(&rtc.noise);
    printf("BRINGUP SUMMARY %s %u/%u passed%s%s%s%s\n", fail || total < BU_COUNT ? "FAIL" : "PASS", pass, (unsigned)BU_COUNT,
           fail ? "; FAIL:" : "", failed, skip ? "; SKIP:" : "", skipped);
    static char line[120];
    snprintf(line, sizeof(line), "SUMMARY %s %u/%u passed. Press the side button to run again.",
             fail || total < BU_COUNT ? "FAIL" : "PASS", pass, (unsigned)BU_COUNT);
    show_results(line);
}

/* ---------------------------------------------------------------- stages */
static bool bring_up_basics(void)
{
    slab_buzzer_init();
    slab_analog_init();
    if (slab_i2c_init() != ESP_OK) return false;
    max17048_hibernate(false);
    if (slab_board_periph_power(true) != ESP_OK) return false;
    st7365p_config_t cfg;
    st7365p_default_config(&cfg);
    if (!fb) fb = heap_caps_calloc((size_t)GFX_W * GFX_H, 2, MALLOC_CAP_SPIRAM);
    if (!shadow) shadow = heap_caps_calloc((size_t)GFX_W * GFX_H, 2, MALLOC_CAP_SPIRAM);
    screen_ok = fb && shadow && st7365p_init(&cfg) == ESP_OK;
    slab_cal_t cal;
    slab_backlight_init(slab_cal_load(&cal) ? cal.bl_pwm_hz : CONFIG_SLAB_BL_FALLBACK_HZ);
    slab_backlight_set_permille(600);
    return true;
}

static void wake_result(int id, esp_sleep_wakeup_cause_t want, const char *what)
{
    esp_sleep_wakeup_cause_t cause = esp_sleep_get_wakeup_cause();
    long secs = (long)((wall_us() - rtc.sleep_us) / 1000000);
    if (cause == want) result(id, BU_PASS, "woke on %s after %ld s", what, secs);
    else result(id, BU_FAIL, "no %s wake in %d s (cause %d)", what, CONFIG_SLAB_WAKE_TIMEOUT_S, (int)cause);
}

static void run_first_boot(void)
{
    char line[160];
    slab_board_describe(line, sizeof(line));
    result(BU_BOOT, BU_PASS, "%s", line);
    slab_buzzer_init();
    test_vbus();
    test_i2c();
    if (rtc.r[BU_I2C].status != BU_PASS) printf("BRINGUP I2C failed: later I2C blocks will fail too\n");
    test_battery();
    test_haptic();
    test_touch();
    test_periph();
    start_screen();
    show_results(NULL);
    test_card();
    test_noise();
    test_button_and_screen();
    test_buzzer();
    test_wheel();
    show_results("Deep sleep test: the screen goes dark. Press the side button to wake.");
    sleep_ms(4000);
    go_to_sleep(1);
}

void app_main(void)
{
    esp_sleep_wakeup_cause_t cause = esp_sleep_get_wakeup_cause();
    bool resumed = rtc.magic == MAGIC && rtc.stage &&
        (cause == ESP_SLEEP_WAKEUP_EXT0 || cause == ESP_SLEEP_WAKEUP_EXT1 || cause == ESP_SLEEP_WAKEUP_TIMER);
    if (!resumed) { memset(&rtc, 0, sizeof(rtc)); rtc.magic = MAGIC; }
    printf("BRINGUP Harmony Mark-8 slab rev A bring-up %s, stage %u, wake cause %d\n",
           esp_app_get_description()->version, rtc.stage, (int)cause);
    esp_err_t err = nvs_flash_init();
    if (err == ESP_ERR_NVS_NO_FREE_PAGES || err == ESP_ERR_NVS_NEW_VERSION_FOUND) {
        nvs_flash_erase();
        nvs_flash_init();
    }
    if (slab_board_init() != ESP_OK) {
        result(BU_BOOT, BU_FAIL, "not a slab board (package, flash, PSRAM or MAC): outputs untouched");
        summary();
        return;
    }
    if (!resumed) run_first_boot();
    else if (rtc.stage == 1) {
        rtc.stage = 0;
        bring_up_basics();
        wake_result(BU_WAKE_BUTTON, ESP_SLEEP_WAKEUP_EXT0, "side button");
        if (start_touch() != ESP_OK) printf("BRINGUP MPR121 restart failed\n");
        show_results("Second sleep: the screen goes dark. Touch the wheel to wake it (hold about 1 s).");
        sleep_ms(5000);
        go_to_sleep(2);
    } else {
        rtc.stage = 0;
        bring_up_basics();
        wake_result(BU_WAKE_TOUCH, ESP_SLEEP_WAKEUP_EXT1, "wheel touch");
        mpr121_wait_untouched(3000);   /* learn the baselines with the finger off */
        start_touch();
        summary();
        wait_press(0xFFFFFFFFu);
        esp_restart();
    }
}
