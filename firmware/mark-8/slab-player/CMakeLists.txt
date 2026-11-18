cmake_minimum_required(VERSION 3.16)
# Shared slab components (board, touch, screen, Mark-8 bench_storage) and the
# unchanged Mark-6 MP3 components, as firmware/mark-7/pocket-player does.
set(EXTRA_COMPONENT_DIRS "../components" "../../mark-6/components/bench_mp3" "../../mark-6/components/minimp3")
execute_process(COMMAND git --no-optional-locks describe --always --dirty --exclude "*"
    WORKING_DIRECTORY "${CMAKE_CURRENT_LIST_DIR}" OUTPUT_VARIABLE HARMONY_REV OUTPUT_STRIP_TRAILING_WHITESPACE)
set(PROJECT_VER "mark8-${HARMONY_REV}")
include($ENV{IDF_PATH}/tools/cmake/project.cmake)
project(mark8_slab_player)
