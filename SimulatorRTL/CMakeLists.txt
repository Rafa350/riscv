set(TARGET_NAME "SimulatorRTL")

# Localitza Verilator
#
set(VERILATOR_ROOT /usr/local/share/verilator)
find_package(
    verilator
    HINTS $ENV{VERILATOR_ROOT} ${VERILATOR_ROOT}
)
if (NOT verilator_FOUND)
    message(FATAL_ERROR "Verilator was not found. Either install it, or set the VERILATOR_ROOT environment variable")
endif()


# Defineix els directoris
#
set(SOURCE_DIR            ${CMAKE_CURRENT_SOURCE_DIR})

set(SIMULATOR_DIR         ${CMAKE_SOURCE_DIR}/Simulator)
Set(SIMULATOR_INCLUDE_DIR ${SIMULATOR_DIR}/Include)
set(SIMULATOR_SOURCE_DIR  ${SIMULATOR_DIR}/Source)

set(SIMLIB_DIR            ${CMAKE_SOURCE_DIR}/../Simulation)
set(SIMLIB_INCLUDE_DIR    ${SIMLIB_DIR}/Include)
set(SIMLIB_SOURCE_DIR     ${SIMLIB_DIR}/Source)

set(HDL_DIR               ${CMAKE_SOURCE_DIR}/HDL)
set(HDL_INCLUDE_DIR       ${HDL_DIR})


# Opcions de verilacio
#
set(VERILATOR_OPTIONS
    -cc 
    -Wall 
    --no-timing
    --x-initial unique
    --x-assign unique
    --no-assert
    --compiler gcc
)

# Opcions de compilacio
#
set(COMPILE_OPTIONS
    -O3
    -ffunction-sections 
    -fdata-sections
)

# Opcions d'enllaçat
#
set(LINK_OPTIONS
    -Wl,--gc-sections 
)


# Mostra la configuracio
#
message("* ------------------------------------------------------------------------------------")
message("* Project '${PROJECT_NAME}/${TARGET_NAME}' configuration.")
message("*   Toochain:")
message("*     gcc         : " ${CMAKE_C_COMPILER})
message("*     g++         : " ${CMAKE_CXX_COMPILER})
message("*     as          : " ${CMAKE_ASM_COMPILER})
message("*")
message("*   Directories:")
message("*     Root        : " ${CMAKE_SOURCE_DIR})
message("*     Current     : " ${CMAKE_CURRENT_SOURCE_DIR})
message("*")
message("*     HDL Source  : " ${HDL_DIR})
message("*     C++ Source  : " ${SOURCE_DIR})
message("*                 : " ${SIMULATOR_SOURCE_DIR})
message("*                 : " ${SIMLIB_SOURCE_DIR})
message("*     C++ Include : " ${SIMULATOR_INCLUDE_DIR})
message("*                 : " ${SIMLIB_INCLUDE_DIR})
message("*")


# Genera el executable
add_executable(${TARGET_NAME})

set_target_properties(${TARGET_NAME} PROPERTIES
    OUTPUT_NAME "rv-rtlsim")
   
target_sources(${TARGET_NAME} PRIVATE 
    ${SOURCE_DIR}/main.cpp
    ${SIMULATOR_SOURCE_DIR}/RISCVTracer.cpp
    ${SIMULATOR_SOURCE_DIR}/RISCVTracerInfo.cpp
    ${SIMULATOR_SOURCE_DIR}/RISCVTracerDpi.cpp
    ${SIMULATOR_SOURCE_DIR}/RISCVMemory.cpp
    ${SIMULATOR_SOURCE_DIR}/RISCVMemoryDpi.cpp)
            
target_compile_options(${TARGET_NAME} PRIVATE 
    ${COMPILE_OPTIONS})

target_link_options(${TARGET_NAME} PRIVATE 
    ${LINK_OPTIONS})

target_include_directories(${TARGET_NAME} PRIVATE 
    .
    ${VERILATOR_ROOT}/include
    ${SIMULATOR_INCLUDE_DIR}
    ${SIMLIB_INCLUDE_DIR})

# Genera els fitxers CPP de la simulacio
verilate(${TARGET_NAME}
    TOP_MODULE top
    TRACE_FST
    INCLUDE_DIRS ${SOURCE_DIR}
                 ${HDL_INCLUDE_DIR}
                 ${HDL_INCLUDE_DIR}/Base
                 ${HDL_INCLUDE_DIR}/Processor
                 ${HDL_INCLUDE_DIR}/Processor/Core
                 ${HDL_INCLUDE_DIR}/Processor/Core/ALU
                 ${HDL_INCLUDE_DIR}/Processor/Core/FPU
                 ${HDL_INCLUDE_DIR}/Processor/Core/MDU
                 ${HDL_INCLUDE_DIR}/Processor/Core/Stage
                 ${HDL_INCLUDE_DIR}/Processor/Core/Pipeline
                 ${HDL_INCLUDE_DIR}/Processor/Cache
    VERILATOR_ARGS ${VERILATOR_OPTIONS}
    SOURCES verilator_top.sv
)

# Instalacio en la carpeta Run
install(TARGETS ${TARGET_NAME}
    DESTINATION ${CMAKE_SOURCE_DIR}/Run)