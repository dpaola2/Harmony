set(SHARED "${CMAKE_CURRENT_LIST_DIR}/../../feather-carrier/main")
idf_component_register(SRCS "${SHARED}/bt_app_core.c" "${SHARED}/main.c"
    "${SHARED}/audio_player.c" "${SHARED}/player_display.c" "${SHARED}/player_ui.c" "${SHARED}/ui_render.c" "${SHARED}/carrier_controls.c"
    "${SHARED}/album.c" "${SHARED}/album_metadata.c" "${SHARED}/player_prefs.c" "${SHARED}/player_bluetooth.c" "${SHARED}/playback.c" "${SHARED}/input_filter.c"
    PRIV_REQUIRES bt nvs_flash bench_storage bench_mp3 bench_display esp_timer carrier_board esp_driver_i2c
    INCLUDE_DIRS "${SHARED}")
# SD initializes shared SPI2 before player_display_start attaches the LCD.
target_compile_definitions(${COMPONENT_LIB} PRIVATE bench_display_init=bench_display_init_on_existing_bus)

target_compile_definitions(${COMPONENT_LIB} PRIVATE HARMONY_PLAYER_UI=1)
