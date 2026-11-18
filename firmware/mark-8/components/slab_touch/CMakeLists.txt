idf_component_register(
    SRCS "mpr121_regs.c" "mpr121.c" "wheel.c" "slab_wheel.c"
    INCLUDE_DIRS "include"
    REQUIRES slab_board esp_driver_gpio esp_timer)
