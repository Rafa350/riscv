cmake_minimum_required(VERSION 3.16.3)
project("rv-rtlsim")
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


set(TARGET_NAME ${PROJECT_NAME})

# Defineix els directoris
#
set(SIMLIB_DIR            ${PROJECT_DIR}/../Simulation)
set(SIMLIB_INCLUDE_DIR    ${SIMLIB_DIR}/Include)
set(SIMLIB_SOURCE_DIR     ${SIMLIB_DIR}/Source)

set(SIMULATOR_DIR         ${PROJECT_DIR}/Simulator)
set(SIMULATOR_INCLUDE_DIR ${SIMULATOR_DIR}/Include)
set(SIMULATOR_SOURCE_DIR  ${SIMULATOR_DIR}/Source)

set(SOURCE_DIR            ${CMAKE_CURRENT_SOURCE_DIR})


set(HDL_INCLUDE_DIR       ${PROJECT_DIR}/HDL)


message("* ------------------------------------------------------------------------------------")
message("* Sub-project '${PROJECT_NAME}' configuration.")
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
add_executable(
    ${TARGET_NAME})
target_sources(
    ${TARGET_NAME}
    PRIVATE ${SOURCE_DIR}/main.cpp
            ${SIMULATOR_SOURCE_DIR}/RISCVTracer.cpp
            ${SIMULATOR_SOURCE_DIR}/RISCVTracerDpi.cpp
            ${SIMULATOR_SOURCE_DIR}/RISCVMemory.cpp)
target_include_directories(
    ${TARGET_NAME}
    PRIVATE .
            ${VERILATOR_ROOT}/include
            ${SIMLIB_INCLUDE_DIR}
            ${SIMULATOR_INCLUDE_DIR})

# Genera els fitxers CPP de la simulacio
verilate(${TARGET_NAME}
    TOP_MODULE top
    TRACE_FST
    INCLUDE_DIRS ${HDL_INCLUDE_DIR}
                 ${HDL_INCLUDE_DIR}/Base
                 ${HDL_INCLUDE_DIR}/Core
                 ${HDL_INCLUDE_DIR}/Core/ALU
                 ${HDL_INCLUDE_DIR}/Core/Stage
                 ${HDL_INCLUDE_DIR}/Core/Pipeline
    VERILATOR_ARGS
    SOURCES verilator_top.sv
)

# Instalacio en la carpeta Run
install(
    TARGETS ${TARGET_NAME}
    DESTINATION ${PROJECT_DIR}/Run)