set(SHARED "${CMAKE_CURRENT_LIST_DIR}/../../../mark-6/feather-carrier/main")
if(CONFIG_MARK7_ANO_INPUT)
    set(CONTROL_SOURCES "${SHARED}/carrier_controls.c" "${SHARED}/input_filter.c")
else()
    set(CONTROL_SOURCES "wheel_input.c" "wheel_protocol.c")
endif()
idf_component_register(SRCS "main.c" "player_power.c" "player_display.c" "ui_render.c" ${CONTROL_SOURCES}
    "${SHARED}/audio_player.c" "${SHARED}/player_ui.c"
    "${SHARED}/album.c" "${SHARED}/album_metadata.c" "${SHARED}/player_prefs.c"
    "${SHARED}/player_bluetooth.c" "${SHARED}/playback.c"
    PRIV_REQUIRES esp_adc bt nvs_flash bench_storage bench_mp3 bench_display esp_timer carrier_board
    INCLUDE_DIRS "." "${SHARED}")
target_compile_definitions(${COMPONENT_LIB} PRIVATE HARMONY_MARK7_POWER=1 HARMONY_PLAYER_UI=1 PLAYER_UI_ROWS=4
    HARMONY_DEVICE_NAME="Harmony Mark-7" bench_display_init=bench_display_init_on_existing_bus)

# Pixel rendering is a hot path; keep the rest of the debug build unchanged.
set_source_files_properties(ui_render.c player_display.c PROPERTIES COMPILE_OPTIONS "-O2")
