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

/* Revision A.2 Q4 gate network (hardware README "Power"): R13 2.2k and R14 1k
 * form a divider from GPIO13, R34 4.7k and C26 100 nF (gate to drain) set a
 * Miller ramp, C18 1 uF holds the gate while 3V3 comes up. 3V3_PERIPH reaches
 * 90 percent 3.3 to 10.1 ms after GPIO13 goes low; this wait adds margin
 * (firmware change 1). The divider also holds Q4 off from reset release until
 * firmware drives GPIO13 low: the internal pull-down leaves VGS at -0.09 to
 * -0.22 V. The GPIO13 polarity is unchanged: low is on. */
#define SLAB_PERIPH_RAMP_MS 20

/* After GPIO13 goes high the rail drains through its loads: about 0.4 s to
 * fall below 0.5 V (hardware README firmware note 6, review CC-2). The card
 * needs that power cycle, so the rail stays off at least this long before it
 * comes back. Q4 also turns off at every chip reset. */
#define SLAB_PERIPH_DRAIN_MS 500

/* Pure: milliseconds still to wait before switching the rail back on, when it
 * was switched off (or the chip reset with the rail on) ms_since_off ago.
 * `drained` is true when the rail has been off for a long time (power-on, deep
 * sleep wake). */
unsigned slab_periph_drain_wait_ms(bool drained, unsigned ms_since_off);

/* Lines low (or input), then GPIO13 low, then wait for the ramp.
 * Afterwards LCD_CS stays low (touch rule 1) and SD_CS is high (card idle). */
int slab_periph_on(const slab_gpio_ops_t *ops);
/* Backlight off, lines low (or input), then GPIO13 high. */
int slab_periph_off(const slab_gpio_ops_t *ops);

/* The ESP-IDF implementation of the operations. */
const slab_gpio_ops_t *slab_gpio_ops_idf(void);
