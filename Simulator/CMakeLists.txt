cmake_minimum_required(VERSION 3.16.0)


add_executable(
    RISCVSim)
target_include_directories(
    RISCVSim
    PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}/Include)
target_sources(
    RISCVSim
    PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}/main.cpp
           ${CMAKE_CURRENT_SOURCE_DIR}/Source/RISCVSim.cpp
           ${CMAKE_CURRENT_SOURCE_DIR}/Source/RISCVTracer.cpp)

#set(CPACK_PROJECT_NAME ${PROJECT_NAME})
#set(CPACK_PROJECT_VERSION ${PROJECT_VERSION})
#include(CPack)
