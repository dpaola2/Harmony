/* Back-power-safe 3V3_PERIPH sequence. Pure logic over an operations table. */
#include "slab_power_seq.h"
#include "slab_pins.h"

const slab_periph_line_t slab_periph_lines[] = {
    {SLAB_PIN_LCD_SCK, false}, {SLAB_PIN_LCD_MOSI, false}, {SLAB_PIN_LCD_CS, false},
    {SLAB_PIN_LCD_DC, false}, {SLAB_PIN_LCD_RST, false},
    {SLAB_PIN_SD_SCK, false}, {SLAB_PIN_SD_MOSI, false}, {SLAB_PIN_SD_CS, false},
    /* The card drives MISO; the screen drives TE (GPIO39 is input only). */
    {SLAB_PIN_SD_MISO, true}, {SLAB_PIN_LCD_TE, true},
};
const unsigned slab_periph_line_count = sizeof(slab_periph_lines) / sizeof(slab_periph_lines[0]);

static int lines_safe(const slab_gpio_ops_t *ops)
{
    for (unsigned i = 0; i < slab_periph_line_count; ++i) {
        const slab_periph_line_t *l = &slab_periph_lines[i];
        int err = l->input ? ops->input(l->gpio) : ops->output(l->gpio, 0);
        if (err) return err;
    }
    return 0;
}

int slab_periph_on(const slab_gpio_ops_t *ops)
{
    int err = ops->output(SLAB_PIN_LCD_BL, 0);
    if (!err) err = lines_safe(ops);
    if (!err) err = ops->output(SLAB_PIN_PERIPH_EN_N, 0);
    if (err) return err;
    ops->delay_ms(SLAB_PERIPH_RAMP_MS);
    /* LCD_CS is already low and stays low. SD_CS idles high once the card has power. */
    return ops->output(SLAB_PIN_SD_CS, 1);
}

int slab_periph_off(const slab_gpio_ops_t *ops)
{
    int err = ops->output(SLAB_PIN_LCD_BL, 0);
    if (!err) err = lines_safe(ops);
    if (!err) err = ops->output(SLAB_PIN_PERIPH_EN_N, 1);
    return err;
}
