cmake_minimum_required(VERSION 3.16)
set(EXTRA_COMPONENT_DIRS "../../mark-6/components/bench_mp3" "../../mark-6/components/minimp3"
    "../../mark-6/feather-player-bench/components/bench_storage")
execute_process(COMMAND git describe --always --dirty --exclude "*"
    WORKING_DIRECTORY "${CMAKE_CURRENT_LIST_DIR}" OUTPUT_VARIABLE HARMONY_REV OUTPUT_STRIP_TRAILING_WHITESPACE)
set(PROJECT_VER "mark7-${HARMONY_REV}")
include($ENV{IDF_PATH}/tools/cmake/project.cmake)
project(mark7_pocket_player)
