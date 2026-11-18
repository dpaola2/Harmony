cmake_minimum_required(VERSION 3.16)
# Shared slab components: board, touch, screen, and the Mark-8 copy of bench_storage.
set(EXTRA_COMPONENT_DIRS "../components")
execute_process(COMMAND git --no-optional-locks describe --always --dirty --exclude "*"
    WORKING_DIRECTORY "${CMAKE_CURRENT_LIST_DIR}" OUTPUT_VARIABLE HARMONY_REV OUTPUT_STRIP_TRAILING_WHITESPACE)
set(PROJECT_VER "mark8-bringup-${HARMONY_REV}")
include($ENV{IDF_PATH}/tools/cmake/project.cmake)
project(mark8_slab_bringup)
