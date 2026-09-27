idf_component_register(SRCS "bt_app_core.c"
                            "main.c" "audio_player.c" "player_display.c" "player_ui.c" "ui_render.c" "carrier_controls.c" "album.c" "playback.c" "input_filter.c"
                    PRIV_REQUIRES bt nvs_flash bench_storage bench_mp3 bench_display esp_timer carrier_board esp_driver_i2c
                    INCLUDE_DIRS ".")

target_compile_definitions(${COMPONENT_LIB} PRIVATE HARMONY_PLAYER_UI=1)
