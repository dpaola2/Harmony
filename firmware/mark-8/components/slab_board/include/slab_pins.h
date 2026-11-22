#pragma once
/* Harmony Mark-8 "slab" revision A. GPIO numbers, not module pins.
 * Source: hardware/mark-8/slab-rev-a/README.md "ESP32 pin map" (the built
 * board; it matches SPEC 5.3). tests/verify.py checks every value below
 * against that table. */

/* Screen: ST7365P, 4-line SPI on HSPI (SPI2). The only device on its bus. */
#define SLAB_PIN_LCD_SCK      14
#define SLAB_PIN_LCD_MOSI     27
#define SLAB_PIN_LCD_CS       26   /* held low while the screen has power (touch rule 1) */
#define SLAB_PIN_LCD_DC       33
#define SLAB_PIN_LCD_RST      32
#define SLAB_PIN_LCD_BL        4   /* Q5 gate (low-side backlight switch), PWM */
#define SLAB_PIN_LCD_TE       39   /* input only; left unused (touch rule 2). If it ever
                                      becomes an edge interrupt, mask it around ADC1 reads:
                                      GPIO39 glitches low while ADC1 is powered (review ESP32-6) */

/* microSD on its own VSPI (SPI3) bus. */
#define SLAB_PIN_SD_SCK        5
#define SLAB_PIN_SD_MOSI      19
#define SLAB_PIN_SD_MISO      21   /* 10k pull-up to 3V3_PERIPH */
#define SLAB_PIN_SD_CS        25   /* 10k pull-up to 3V3_PERIPH; ADC2 channel 8 */
#define SLAB_PIN_SD_CD        15   /* low when a card is in; 1M pull-up (R25) to 3V3; MTDO strap */

/* I2C: MAX17048 0x36, DRV2605L 0x5A, MPR121 0x5B. External 4.7k pull-ups. */
#define SLAB_PIN_I2C_SDA      22
#define SLAB_PIN_I2C_SCL      20
#define SLAB_PIN_TOUCH_IRQ    34   /* input only, 10k pull-up, ext1 wake */

#define SLAB_PIN_SIDE_BTN     38   /* input only, 100k pull-up, low when pressed, ext0 wake */
#define SLAB_PIN_BUZZER        2   /* Q6 gate, 100k pull-down holds the strap low */
#define SLAB_PIN_PERIPH_EN_N  13   /* low turns on 3V3_PERIPH (screen and card) */
#define SLAB_PIN_VBAT_SENSE   35   /* ADC1 channel 7, VBAT through 1M / 1M */
#define SLAB_PIN_VBUS_SENSE   36   /* ADC1 channel 0, VBUS through 100k / 75k, no filter cap */

#define SLAB_I2C_ADDR_MAX17048 0x36
#define SLAB_I2C_ADDR_DRV2605L 0x5A
#define SLAB_I2C_ADDR_MPR121   0x5B

/* Divider ratios as (top + bottom) / bottom, in thousandths. */
#define SLAB_VBAT_DIVIDER_X1000 2000   /* 1M / 1M */
#define SLAB_VBUS_DIVIDER_X1000 2333   /* R29 100k / R30 75k: 175 / 75 (revision A.2, review BN-2) */

/* Panel geometry. */
#define SLAB_LCD_WIDTH  320
#define SLAB_LCD_HEIGHT 320
