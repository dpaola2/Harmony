# Mark-6 player core, used unchanged from the working tree (see README "Uncommitted dependencies").
set(SHARED "${CMAKE_CURRENT_LIST_DIR}/../../../mark-6/feather-carrier/main")
idf_component_register(
    SRCS "main.c" "player_power.c" "player_display.c" "slab_render.c" "slab_controls.c" "controls_map.c"
         "${SHARED}/audio_player.c" "${SHARED}/player_ui.c" "${SHARED}/album.c" "${SHARED}/album_metadata.c"
         "${SHARED}/player_prefs.c" "${SHARED}/player_bluetooth.c" "${SHARED}/playback.c"
    PRIV_REQUIRES bt nvs_flash esp_timer esp_driver_gpio esp_driver_uart
                  slab_board slab_touch st7365p bench_storage bench_mp3
    INCLUDE_DIRS "." "${SHARED}")
target_compile_definitions(${COMPONENT_LIB} PRIVATE HARMONY_PLAYER_UI=1 PLAYER_UI_ROWS=6
    HARMONY_DEVICE_NAME="Harmony Mark-8")

# Pixel rendering is a hot path; keep the rest of the debug build unchanged.
set_source_files_properties(slab_render.c player_display.c PROPERTIES COMPILE_OPTIONS "-O2")
