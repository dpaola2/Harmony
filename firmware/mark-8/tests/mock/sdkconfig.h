/* Host-test configuration. tests/verify.py checks every value against the
 * Kconfig defaults so the tests exercise what a default build runs. */
#pragma once
#define CONFIG_SLAB_LCD_SPI_HZ 40000000
#define CONFIG_SLAB_LCD_MADCTL 0x48
#define CONFIG_SLAB_LCD_COL_OFFSET 0
#define CONFIG_SLAB_LCD_ROW_OFFSET 0
#define CONFIG_SLAB_TOUCH_THRESHOLD 12
#define CONFIG_SLAB_RELEASE_THRESHOLD 6
#define CONFIG_SLAB_WHEEL_STEP_DEG 15
#define CONFIG_SLAB_WHEEL_START_DEG 20
#define CONFIG_SLAB_WHEEL_TAP_MAX_MS 400
#define CONFIG_SLAB_WHEEL_TAP_MAX_DEG 12
#define CONFIG_SLAB_WHEEL_HOLD_MS 700
#define CONFIG_SLAB_WHEEL_ZONE_HALF_DEG 40
#define CONFIG_SLAB_BL_BRIGHTNESS_PCT 80
