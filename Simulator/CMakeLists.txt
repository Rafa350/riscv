cmake_minimum_required(VERSION 3.16.0)
project("rv-bhvsim")


set(TARGET_NAME ${PROJECT_NAME})


# Genera l'executable
add_executable(
    ${TARGET_NAME})
target_include_directories(
    ${TARGET_NAME}
    PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}/Include)
target_sources(
    ${TARGET_NAME}
    PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}/main.cpp
           ${CMAKE_CURRENT_SOURCE_DIR}/Source/RISCVProcessor.cpp
           ${CMAKE_CURRENT_SOURCE_DIR}/Source/RISCVMemory.cpp
           ${CMAKE_CURRENT_SOURCE_DIR}/Source/RISCVTracer.cpp)

# Instalacio en la carpeta Run
install(
    TARGETS ${TARGET_NAME}
    DESTINATION ${PROJECT_DIR}/Run)