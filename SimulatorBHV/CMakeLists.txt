set(TARGET_NAME "SimulatorBHV")


# Defineix els directoris
#
set(SOURCE_DIR            ${CMAKE_CURRENT_SOURCE_DIR})

set(SIMULATOR_DIR         ${CMAKE_SOURCE_DIR}/Simulator)
Set(SIMULATOR_INCLUDE_DIR ${SIMULATOR_DIR}/Include)
set(SIMULATOR_SOURCE_DIR  ${SIMULATOR_DIR}/Source)


# Opcions de compilacio
#
set(COMPILE_OPTIONS
    -O3
    -Wall
    -ffunction-sections 
    -fdata-sections
)


# Opcion d'enllaçat
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
message("*     C++ Source  : " ${SOURCE_DIR})
message("*                 : " ${SIMULATOR_INCLUDE_DIR})
message("*     C++ Include : " ${SIMULATOR_SOURCE_DIR})
message("*")


# Genera l'executable
add_executable(${TARGET_NAME})

target_compile_options(${TARGET_NAME} PRIVATE 
    ${COMPILE_OPTIONS})
    
target_link_options(${TARGET_NAME} PRIVATE
    ${LINK_OPTIONS})

target_include_directories(${TARGET_NAME} PUBLIC 
    .
    ${SIMULATOR_INCLUDE_DIR}
    ${SIMLIB_INCLUDE_DIR})

target_sources(${TARGET_NAME} PUBLIC 
    ${SOURCE_DIR}/main.cpp
    ${SIMULATOR_SOURCE_DIR}/RISCVProcessor.cpp
    ${SIMULATOR_SOURCE_DIR}/RISCVMemory.cpp
    ${SIMULATOR_SOURCE_DIR}/RISCVTracer.cpp
    ${SIMULATOR_SOURCE_DIR}/RISCVTracerInfo.cpp)

# Instalacio en la carpeta Run
#install(
#    TARGETS ${TARGET_NAME}
#    DESTINATION ${PROJECT_DIR}/Run)