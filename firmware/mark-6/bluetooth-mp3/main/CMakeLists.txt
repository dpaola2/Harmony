idf_component_register(SRCS "bt_app_core.c"
                            "main.c" "audio_player.c" "player_display.c"
                    PRIV_REQUIRES bt nvs_flash bench_storage bench_mp3 bench_display esp_timer
                    INCLUDE_DIRS ".")
