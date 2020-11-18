cmake_minimum_required(VERSION 3.8)
project(simx)


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


# Defineix els directoris del paquet 'Simulation'
#
set(SIM_PACK_ROOT ../../Simulation)
set(SIM_PACK_INC ${SIM_PACK_ROOT}/Include)
set(SIM_PACK_SRC ${SIM_PACK_ROOT}/Source)


# El executable de la simulacio
#
add_executable(simx 
    ../sim_main.cpp
    ../sim_dis.cpp
    ../sim_ram.cpp
    ../sim_rom.cpp
    ../sim_dpi.cpp
    ${SIM_PACK_SRC}/simMemory.cpp
)


# Els directoris a incluir
#
target_include_directories(simx
    PRIVATE .
    PRIVATE ${VERILATOR_ROOT}/include
    PRIVATE ${SIM_PACK_INC}    
)


# El hardware a simular
#
verilate(simx
    TOP_MODULE top
    TRACE_FST
    INCLUDE_DIRS ../HDL ../HDL/Base ../HDL/Core
    VERILATOR_ARGS 
    SOURCES verilator_top.sv
)
