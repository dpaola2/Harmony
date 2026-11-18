# font8x16.h comes from the committed Mark-6 bench display component.
set(MARK6_FONT "${CMAKE_CURRENT_LIST_DIR}/../../../mark-6/components/bench_display")
idf_component_register(SRCS "bringup.c" "bringup_ui.c" "gfx.c" "noise_stats.c"
    INCLUDE_DIRS "." "${MARK6_FONT}"
    PRIV_REQUIRES slab_board slab_touch st7365p bench_storage nvs_flash esp_adc esp_timer
                  esp_driver_gpio esp_driver_uart sdmmc fatfs esp_app_format)
set_source_files_properties(gfx.c bringup_ui.c PROPERTIES COMPILE_OPTIONS "-O2")
