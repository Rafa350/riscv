cmake_minimum_required(VERSION 3.16.3)
project(rv)

set(PROJECT_DIR ${PROJECT_SOURCE_DIR})

add_subdirectory(Firmware)
add_subdirectory(Verilator)
add_subdirectory(Simulator)
add_subdirectory(Testbench)
