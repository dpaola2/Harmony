/* Slab board identity, idle pin states and 3V3_PERIPH switching. */
#include <stdio.h>
#include <string.h>
#include "sdkconfig.h"
#include "slab_board.h"
#include "slab_power_seq.h"
#include "driver/gpio.h"
#include "driver/rtc_io.h"
#include "esp_chip_info.h"
#include "esp_efuse.h"
#include "esp_flash.h"
#include "esp_log.h"
#include "esp_mac.h"
#include "esp_psram.h"
#include "esp_system.h"
#include "esp_sleep.h"
#include "soc/efuse_defs.h"
#include "freertos/FreeRTOS.h"
#include "freertos/task.h"

#ifndef CONFIG_SLAB_EXPECTED_MAC
#define CONFIG_SLAB_EXPECTED_MAC ""
#endif

static const char *TAG = "SLAB";
static bool ready, periph_on;

static int idf_output(int gpio, int level)
{
    gpio_config_t c = {.pin_bit_mask = 1ULL << gpio, .mode = GPIO_MODE_OUTPUT,
        .pull_up_en = GPIO_PULLUP_DISABLE, .pull_down_en = GPIO_PULLDOWN_DISABLE,
        .intr_type = GPIO_INTR_DISABLE};
    /* Latch the level first so the pin never glitches the other way. */
    esp_err_t err = gpio_set_level(gpio, level);
    if (err == ESP_OK) err = gpio_config(&c);
    if (err == ESP_OK) err = gpio_set_level(gpio, level);
    return err;
}

static int idf_input(int gpio)
{
    gpio_config_t c = {.pin_bit_mask = 1ULL << gpio, .mode = GPIO_MODE_INPUT,
        .pull_up_en = GPIO_PULLUP_DISABLE, .pull_down_en = GPIO_PULLDOWN_DISABLE,
        .intr_type = GPIO_INTR_DISABLE};
    return gpio_config(&c);
}

static void idf_delay(unsigned ms) { vTaskDelay(pdMS_TO_TICKS(ms ? ms : 1)); }

static const slab_gpio_ops_t idf_ops = {idf_output, idf_input, idf_delay};
const slab_gpio_ops_t *slab_gpio_ops_idf(void) { return &idf_ops; }

bool slab_board_ready(void) { return ready; }
bool slab_board_periph_powered(void) { return periph_on; }

void slab_board_describe(char *out, size_t size)
{
    esp_chip_info_t chip;
    esp_chip_info(&chip);
    uint8_t mac[6] = {0};
    uint32_t flash = 0;
    esp_read_mac(mac, ESP_MAC_WIFI_STA);
    esp_flash_get_size(NULL, &flash);
    size_t psram = esp_psram_is_initialized() ? esp_psram_get_size() : 0;
    unsigned pkg = (unsigned)esp_efuse_get_pkg_ver();
    snprintf(out, size, "%s rev %u.%u, flash %u MB, PSRAM %u MB, MAC %02x:%02x:%02x:%02x:%02x:%02x, reset %d",
        pkg == EFUSE_RD_CHIP_VER_PKG_ESP32PICOV302 ? "ESP32-PICO-V3-02" : "unexpected package",
        chip.revision / 100, chip.revision % 100, (unsigned)(flash >> 20), (unsigned)(psram >> 20),
        mac[0], mac[1], mac[2], mac[3], mac[4], mac[5], (int)esp_reset_reason());
}

static void release_holds(void)
{
    const int rtc_pins[] = {SLAB_PIN_PERIPH_EN_N, SLAB_PIN_LCD_BL, SLAB_PIN_BUZZER,
        SLAB_PIN_TOUCH_IRQ, SLAB_PIN_SIDE_BTN};
    for (unsigned i = 0; i < sizeof(rtc_pins) / sizeof(rtc_pins[0]); ++i) {
        rtc_gpio_hold_dis(rtc_pins[i]);
        if (rtc_gpio_is_valid_gpio(rtc_pins[i])) rtc_gpio_deinit(rtc_pins[i]);
    }
    gpio_deep_sleep_hold_dis();
    for (unsigned i = 0; i < slab_periph_line_count; ++i) {
        int g = slab_periph_lines[i].gpio;
        if (rtc_gpio_is_valid_gpio(g)) rtc_gpio_hold_dis(g);   /* also GPIO39, which gpio_hold_dis refuses */
        else gpio_hold_dis(g);
    }
}

esp_err_t slab_board_init(void)
{
    if (ready) return ESP_OK;
    uint8_t mac[6];
    uint32_t flash = 0;
    esp_err_t err = esp_read_mac(mac, ESP_MAC_WIFI_STA);
    if (err == ESP_OK) err = esp_flash_get_size(NULL, &flash);
    if (err != ESP_OK) return err;
    bool package = esp_efuse_get_pkg_ver() == EFUSE_RD_CHIP_VER_PKG_ESP32PICOV302;
    bool psram = esp_psram_is_initialized() && esp_psram_get_size() == 2 * 1024 * 1024;
    if (!package || flash != 8 * 1024 * 1024 || !psram || !slab_mac_matches(CONFIG_SLAB_EXPECTED_MAC, mac)) {
        ESP_LOGE(TAG, "Not a slab board (package %s, flash %u MB, PSRAM %s, MAC %s); outputs left alone",
            package ? "ok" : "wrong", (unsigned)(flash >> 20), psram ? "2 MB" : "missing",
            slab_mac_matches(CONFIG_SLAB_EXPECTED_MAC, mac) ? "ok" : "not CONFIG_SLAB_EXPECTED_MAC");
        return ESP_ERR_INVALID_STATE;
    }
    release_holds();
    /* Idle state: Q4 off first, then every screen and card line low. */
    err = idf_output(SLAB_PIN_PERIPH_EN_N, 1);
    if (err == ESP_OK) err = idf_output(SLAB_PIN_BUZZER, 0);
    if (err == ESP_OK) err = slab_periph_off(&idf_ops);
    const int inputs[] = {SLAB_PIN_TOUCH_IRQ, SLAB_PIN_SIDE_BTN, SLAB_PIN_SD_CD};
    for (unsigned i = 0; err == ESP_OK && i < 3; ++i) err = idf_input(inputs[i]);
    if (err != ESP_OK) return err;
    periph_on = false;
    ready = true;
    char line[160];
    slab_board_describe(line, sizeof(line));
    ESP_LOGI(TAG, "Board: %s; wake cause %d", line, (int)esp_sleep_get_wakeup_cause());
    return ESP_OK;
}

esp_err_t slab_board_periph_power(bool on)
{
    if (!ready) return ESP_ERR_INVALID_STATE;
    esp_err_t err = on ? slab_periph_on(&idf_ops) : slab_periph_off(&idf_ops);
    if (err == ESP_OK) periph_on = on;
    ESP_LOGI(TAG, "3V3_PERIPH %s: %s", on ? "on" : "off", esp_err_to_name(err));
    return err;
}

void slab_board_prepare_deep_sleep(void)
{
    if (periph_on) slab_board_periph_power(false);
    /* Nothing may reach the unpowered screen and card in sleep. RTC pads are
     * isolated (no drive, no pulls, held); the digital-only card pads (5, 19, 21)
     * would fall back to their reset pulls, so they are held low instead. */
    for (unsigned i = 0; i < slab_periph_line_count; ++i) {
        int g = slab_periph_lines[i].gpio;
        if (rtc_gpio_is_valid_gpio(g)) rtc_gpio_isolate(g);
        else { idf_output(g, 0); gpio_hold_en(g); }
    }
    gpio_deep_sleep_hold_en();
    const struct { int gpio, level; } held[] = {
        {SLAB_PIN_PERIPH_EN_N, 1}, {SLAB_PIN_LCD_BL, 0}, {SLAB_PIN_BUZZER, 0}};
    for (unsigned i = 0; i < 3; ++i) {
        rtc_gpio_init(held[i].gpio);
        rtc_gpio_set_direction(held[i].gpio, RTC_GPIO_MODE_OUTPUT_ONLY);
        rtc_gpio_pullup_dis(held[i].gpio);
        rtc_gpio_pulldown_dis(held[i].gpio);
        rtc_gpio_set_level(held[i].gpio, held[i].level);
        rtc_gpio_hold_en(held[i].gpio);
    }
}
