cmake_minimum_required(VERSION 3.16.3)

message("---------------------")
message(${CMAKE_CURRENT_SOURCE_DIR})
message(${CMAKE_CURRENT_BINARY_DIR})
message("---------------------")

set(TOOLCHAIN_FILE riscv-toolchain.cmake)
set(CMAKE_TOOLCHAIN_FILE ${CMAKE_CURRENT_SOURCE_DIR}/${TOOLCHAIN_FILE})
enable_language(ASM C CXX)

message("------------------------------------------------------------")
message("  Toochain configuration file: ${TOOLCHAIN_CFG_FILE}")
message("------------------------------------------------------------")
message("  RISC-V Toolchain")
message("    gcc     - " ${CMAKE_C_COMPILER})
message("    g++     - " ${CMAKE_CXX_COMPILER})
message("    as      - " ${CMAKE_ASM_COMPILER})
message("    objcopy - " ${CMD_OBJCOPY})
message("    objdump - " ${CMD_OBJDUMP})
message("    size    - " ${CMD_SIZE})
message("------------------------------------------------------------")


set(SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR})

project(cpu-riscv-firmware
    VERSION 1.0
    DESCRIPTION "CPU-RISC-V: Firmware"
)

add_executable(main)


target_sources(main
    PRIVATE main.c
)    

target_compile_options(main   
    PRIVATE -Wall
    PRIVATE -Wa,-a
    PRIVATE -march=rv32i
    PRIVATE -mabi=ilp32
)    

#target_link_options(main
#    PRIVATE -T ${SOURCE_DIR}/Linker.ld
#)     
  

  
add_custom_target(
    firmware ALL
    DEPENDS demo.txt
)
    
add_custom_command(
    OUTPUT  demo.txt
    DEPENDS demo.out
    COMMAND ${CMD_OBJCOPY}
    ARGS    --output-target=verilog --only-section=.text demo.out demo.txt
)

add_custom_command(
    OUTPUT  demo.out
    DEPENDS demo.S
    COMMAND ${CMAKE_ASM_COMPILER}
    ARGS    -a -march=rv32i ${SOURCE_DIR}/demo.S -o demo.out
)    

