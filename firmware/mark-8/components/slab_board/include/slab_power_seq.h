#pragma once
/* Back-power-safe switching of 3V3_PERIPH (screen and microSD) through Q4.
 *
 * SPEC 5.3 and hardware README "Power" note 1: before GPIO13 goes high (Q4
 * off), every line to the screen and the card must be low or an input, or the
 * ESP32 back-powers them through their input protection. These functions hold
 * the order. They talk to the pins only through the operations table, so the
 * host tests can check the order with mocks. The SPI buses must already be
 * released (spi_bus_free) before slab_periph_off: the functions take the pins
 * back from the SPI peripheral as plain GPIOs. */
#include <stdbool.h>

typedef struct {
    /* Pin becomes a plain GPIO output at `level`, pulls off. */
    int (*output)(int gpio, int level);
    /* Pin becomes a plain GPIO input, pulls off. */
    int (*input)(int gpio);
    void (*delay_ms)(unsigned ms);
} slab_gpio_ops_t;

/* Every line that connects the ESP32 to a part on 3V3_PERIPH. */
typedef struct { int gpio; bool input; } slab_periph_line_t;
extern const slab_periph_line_t slab_periph_lines[];
extern const unsigned slab_periph_line_count;

/* Turn-on ramp of Q4 (R14 10k, C18 100 nF, about 1 ms) plus margin. */
#define SLAB_PERIPH_RAMP_MS 5

/* Lines low (or input), then GPIO13 low, then wait for the ramp.
 * Afterwards LCD_CS stays low (touch rule 1) and SD_CS is high (card idle). */
int slab_periph_on(const slab_gpio_ops_t *ops);
/* Backlight off, lines low (or input), then GPIO13 high. */
int slab_periph_off(const slab_gpio_ops_t *ops);

/* The ESP-IDF implementation of the operations. */
const slab_gpio_ops_t *slab_gpio_ops_idf(void);
