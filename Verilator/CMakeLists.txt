cmake_minimum_required(VERSION 3.16.3)
project(cpu-riscv-verilator
    VERSION 1.0
    DESCRIPTION "CPU-RISC-V: Verilator"
    LANGUAGES C CXX)


# Localitza Verilator
#
set(VERILATOR_ROOT /home/rafael/Projectes/verilator)
find_package(
    verilator
    HINTS $ENV{VERILATOR_ROOT} ${VERILATOR_ROOT}
)
if (NOT verilator_FOUND)
    message(FATAL_ERROR "Verilator was not found. Either install it, or set the VERILATOR_ROOT environment variable")
endif()


# Defineix els directoris de la llibreria de simulacio
#
set(SIMLIB_ROOT        ${PROJECT_SOURCE_DIR}/../../Simulation)
set(SIMLIB_INCLUDE_DIR ${SIMLIB_ROOT}/Include)
set(SIMLIB_SOURCE_DIR  ${SIMLIB_ROOT}/Source)

set(FIRMWARE_DIR       ${PROJECT_SOURCE_DIR}/../Firmware/build)

set(HDL_INCLUDE_DIR    ${PROJECT_SOURCE_DIR}/../HDL)


# El executable
#
add_executable(simx)


# Els fitxers extra a copiar
#
add_custom_command(
    TARGET simx
    PRE_BUILD
    COMMAND ${CMAKE_COMMAND} -E copy ${FIRMWARE_DIR}/demo.txt firmware.txt
)


# Els fitxers font

target_sources(simx
    PRIVATE ${PROJECT_SOURCE_DIR}/sim_main.cpp
    PRIVATE ${PROJECT_SOURCE_DIR}/sim_dis.cpp
    PRIVATE ${PROJECT_SOURCE_DIR}/sim_ram.cpp
    PRIVATE ${PROJECT_SOURCE_DIR}/sim_access.cpp
    PRIVATE ${SIMLIB_SOURCE_DIR}/simMemory.cpp
)


# Els directoris a incluir
#
target_include_directories(simx
    PRIVATE .
    PRIVATE ${VERILATOR_ROOT}/include
    PRIVATE ${SIMLIB_INCLUDE_DIR}
)


# El hardware a simular
#
verilate(simx
    TOP_MODULE top
    TRACE_FST
    INCLUDE_DIRS ${HDL_INCLUDE_DIR} ${HDL_INCLUDE_DIR}/Base
    VERILATOR_ARGS
    SOURCES verilator_top.sv
)
