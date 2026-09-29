cmake_minimum_required(VERSION 3.16)
set(EXTRA_COMPONENT_DIRS "../components/bench_mp3" "../components/minimp3")
# Visual-reference tags must not label native Mark-6 firmware as Mark-7.
execute_process(COMMAND git describe --always --dirty --exclude "*"
    WORKING_DIRECTORY "${CMAKE_CURRENT_LIST_DIR}" OUTPUT_VARIABLE HARMONY_REV OUTPUT_STRIP_TRAILING_WHITESPACE)
set(PROJECT_VER "mark6-${HARMONY_REV}")
include($ENV{IDF_PATH}/tools/cmake/project.cmake)
project(mark6_feather_carrier)
