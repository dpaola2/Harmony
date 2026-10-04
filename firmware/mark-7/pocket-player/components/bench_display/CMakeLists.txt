set(REFERENCE "${CMAKE_CURRENT_LIST_DIR}/../../../../mark-6/feather-carrier/components/bench_display")
idf_component_register(SRCS "display.c" INCLUDE_DIRS "." "${REFERENCE}"
    REQUIRES driver esp_hw_support carrier_board)
