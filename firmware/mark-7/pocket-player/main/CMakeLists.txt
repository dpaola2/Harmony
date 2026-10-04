set(SHARED "${CMAKE_CURRENT_LIST_DIR}/../../../mark-6/feather-carrier/main")
idf_component_register(SRCS "main.c" "player_display.c" "ui_render.c" "wheel_input.c" "wheel_protocol.c"
    "${SHARED}/audio_player.c" "${SHARED}/player_ui.c"
    "${SHARED}/album.c" "${SHARED}/album_metadata.c" "${SHARED}/player_prefs.c"
    "${SHARED}/player_bluetooth.c" "${SHARED}/playback.c"
    PRIV_REQUIRES bt nvs_flash bench_storage bench_mp3 bench_display esp_timer carrier_board
    INCLUDE_DIRS "." "${SHARED}")
target_compile_definitions(${COMPONENT_LIB} PRIVATE HARMONY_PLAYER_UI=1 PLAYER_UI_ROWS=4
    HARMONY_DEVICE_NAME="Harmony Mark-7" bench_display_init=bench_display_init_on_existing_bus)
