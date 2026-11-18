idf_component_register(
    SRCS "st7365p.c" "slab_dirty.c"
    INCLUDE_DIRS "include"
    REQUIRES slab_board esp_driver_spi esp_driver_gpio heap)

# Pixel copying is a hot path.
set_source_files_properties(st7365p.c slab_dirty.c PROPERTIES COMPILE_OPTIONS "-O2")
