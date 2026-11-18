#pragma once
#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>
#include "esp_err.h"
#include "slab_pins.h"

/* Checks that this is a slab board (ESP32-PICO-V3-02 package, 8 MB flash,
 * 2 MB PSRAM, and CONFIG_SLAB_EXPECTED_MAC when it is set), releases the
 * deep-sleep holds, and puts every peripheral line in its safe idle state:
 * screen and card lines low, 3V3_PERIPH off, backlight and buzzer off.
 * Returns ESP_ERR_INVALID_STATE and leaves the outputs alone on a wrong board. */
esp_err_t slab_board_init(void);
bool slab_board_ready(void);
/* One line: package, revision, flash, PSRAM, MAC, reset reason. */
void slab_board_describe(char *out, size_t size);

/* 3V3_PERIPH on or off through the back-power-safe sequence. The caller frees
 * both SPI buses before switching off. */
esp_err_t slab_board_periph_power(bool on);
bool slab_board_periph_powered(void);

/* Before esp_deep_sleep_start: hold PERIPH_EN_N high (Q4 off), backlight and
 * buzzer gates low, every screen and card line an input. */
void slab_board_prepare_deep_sleep(void);

/* Pure helper: blank `expected` accepts any MAC. Otherwise "aa:bb:cc:dd:ee:ff",
 * case-insensitive. */
bool slab_mac_matches(const char *expected, const uint8_t mac[6]);
