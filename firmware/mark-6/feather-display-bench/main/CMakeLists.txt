idf_component_register(SRCS "main.c" "ano_bench.c" "../../feather-carrier/main/input_filter.c"
    INCLUDE_DIRS "." "../../feather-carrier/main"
    REQUIRES bench_display carrier_board driver esp_timer)
