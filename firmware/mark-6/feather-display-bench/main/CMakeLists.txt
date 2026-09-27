idf_component_register(SRCS "main.c" "ano_bench.c" "sd_bench.c" "../../feather-carrier/main/album.c" "../../feather-carrier/main/input_filter.c"
    INCLUDE_DIRS "." "../../feather-carrier/main"
    REQUIRES bench_display carrier_board driver esp_timer fatfs sdmmc mbedtls)

target_link_options(${COMPONENT_LIB} INTERFACE "-Wl,--wrap=sdmmc_write_sectors" "-Wl,--wrap=sdmmc_card_init")
