idf_component_register(SRCS "bench_storage.c" INCLUDE_DIRS "."
                       REQUIRES fatfs sdmmc esp_driver_spi esp_hw_support)
target_link_options(${COMPONENT_LIB} INTERFACE "-Wl,--wrap=sdmmc_write_sectors" "-Wl,--wrap=sdmmc_card_init")
