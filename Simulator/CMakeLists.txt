set(TARGET_NAME "rv-bhvsim")


# Defineix els directoris
#
set(SOURCE_DIR            ${CMAKE_CURRENT_SOURCE_DIR})


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
    -Wl,--print-gc-sections
)


# Mostra la configuracio
#
message("* ------------------------------------------------------------------------------------")
message("* Project '${PROJECT_NAME}/${TARGET_NAME}' configuration.")
message("*   Toochain:")
message("*     gcc     : " ${CMAKE_C_COMPILER})
message("*     g++     : " ${CMAKE_CXX_COMPILER})
message("*     as      : " ${CMAKE_ASM_COMPILER})
message("*")
message("*   Directories:")
message("*     Root    : " ${CMAKE_SOURCE_DIR})
message("*     Current : " ${CMAKE_CURRENT_SOURCE_DIR})
message("*")


# Genera l'executable
add_executable(${TARGET_NAME})

target_compile_options(${TARGET_NAME} PRIVATE 
    ${COMPILE_OPTIONS})
    
target_link_options(${TARGET_NAME} PRIVATE
    ${LINK_OPTIONS})

target_include_directories(${TARGET_NAME} PUBLIC 
    ${CMAKE_CURRENT_SOURCE_DIR}/Include)

target_sources(${TARGET_NAME} PUBLIC 
    ${CMAKE_CURRENT_SOURCE_DIR}/main.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/Source/RISCVProcessor.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/Source/RISCVMemory.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/Source/RISCVTracer.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/Source/RISCVTracerInfo.cpp)

# Instalacio en la carpeta Run
install(
    TARGETS ${TARGET_NAME}
    DESTINATION ${PROJECT_DIR}/Run)