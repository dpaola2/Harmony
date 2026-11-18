idf_component_register(
    SRCS "slab_board.c" "slab_identity.c" "slab_power_seq.c" "slab_i2c.c"
         "slab_analog.c" "slab_analog_math.c" "slab_backlight.c" "slab_backlight_math.c"
         "slab_buzzer.c" "max17048.c" "max17048_math.c" "drv2605.c" "slab_cal.c"
    INCLUDE_DIRS "include"
    REQUIRES esp_driver_gpio esp_driver_i2c esp_driver_ledc esp_adc esp_timer nvs_flash
             efuse esp_psram spi_flash esp_hw_support)
