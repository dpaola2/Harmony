idf_component_register(SRCS "bench_board.c" INCLUDE_DIRS "." "../../../feather-carrier/components/carrier_board"
                       REQUIRES driver esp_hw_support spi_flash esp_psram)
