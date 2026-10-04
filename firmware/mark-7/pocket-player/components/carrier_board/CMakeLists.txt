set(POLICY "${CMAKE_CURRENT_LIST_DIR}/../../../../mark-6/feather-carrier/components/carrier_board")
idf_component_register(SRCS "board.c" "${POLICY}/carrier_policy.c" INCLUDE_DIRS "." "${POLICY}"
    REQUIRES driver esp_hw_support spi_flash esp_psram)
