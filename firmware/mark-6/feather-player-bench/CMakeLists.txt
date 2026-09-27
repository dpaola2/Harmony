cmake_minimum_required(VERSION 3.16)
set(EXTRA_COMPONENT_DIRS "../components/bench_mp3" "../components/minimp3"
    "../feather-carrier/components/bench_display")
include($ENV{IDF_PATH}/tools/cmake/project.cmake)
project(mark6_feather_player_bench)
