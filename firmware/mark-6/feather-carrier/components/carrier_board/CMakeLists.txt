idf_component_register(SRCS "carrier_board.c" "carrier_policy.c" INCLUDE_DIRS "."
                       REQUIRES esp_driver_gpio esp_hw_support spi_flash esp_psram)
