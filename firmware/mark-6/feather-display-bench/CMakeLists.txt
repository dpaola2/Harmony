cmake_minimum_required(VERSION 3.16)
# Reuse the verified display driver with this bench-only board adapter.
set(EXTRA_COMPONENT_DIRS "${CMAKE_CURRENT_LIST_DIR}/../feather-carrier/components/bench_display")
include($ENV{IDF_PATH}/tools/cmake/project.cmake)
project(mark6_feather_display_bench)
