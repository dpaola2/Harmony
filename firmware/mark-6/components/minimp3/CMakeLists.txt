idf_component_register(SRCS "decoder.c" INCLUDE_DIRS ".")
target_compile_options(${COMPONENT_LIB} PRIVATE -O2)
