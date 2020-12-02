cmake_minimum_required(VERSION 3.16.3)

enable_language(C CXX)


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


# Defineix els directoris
#
set(SIMLIB_DIR         ${PROJECT_DIR}/../Simulation)
set(SIMLIB_INCLUDE_DIR ${SIMLIB_DIR}/Include)
set(SIMLIB_SOURCE_DIR  ${SIMLIB_DIR}/Source)

set(SOURCE_DIR         ${CMAKE_CURRENT_SOURCE_DIR})

set(FIRMWARE_DIR       ${PROJECT_DIR}/build/Firmware)

set(HDL_INCLUDE_DIR    ${PROJECT_DIR}/HDL)


message("*")
message("* Sub-project 'Verilator' configuration.")
message("*   Toochain:")
message("*     gcc     : " ${CMAKE_C_COMPILER})
message("*     g++     : " ${CMAKE_CXX_COMPILER})
message("*     as      : " ${CMAKE_ASM_COMPILER})
message("*")
message("*   Directories:")
message("*     Root    : " ${PROJECT_DIR})
message("*     Current : " ${SOURCE_DIR})
message("*")


# Genera l'executable 
add_executable(simx)
target_sources(simx
    PRIVATE ${SOURCE_DIR}/sim_main.cpp
            ${SOURCE_DIR}/sim_dis.cpp
            ${SOURCE_DIR}/sim_ram.cpp
            ${SOURCE_DIR}/sim_access.cpp
            ${SIMLIB_SOURCE_DIR}/simMemory.cpp)
target_include_directories(simx
    PRIVATE .
    PRIVATE ${VERILATOR_ROOT}/include
    PRIVATE ${SIMLIB_INCLUDE_DIR})

# Copia el fitxer del programa
add_custom_command(
    TARGET simx
    POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E copy ${FIRMWARE_DIR}/main.txt firmware.txt
)

# Genera els fitxers CPP de la simulacio
verilate(simx
    TOP_MODULE top
    TRACE_FST
    INCLUDE_DIRS ${HDL_INCLUDE_DIR} ${HDL_INCLUDE_DIR}/Base
    VERILATOR_ARGS
    SOURCES verilator_top.sv
)
