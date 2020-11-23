cmake_minimum_required(VERSION 3.16.3)

set(TOOLCHAIN_BIN /opt/riscv32/bin)
set(TOOLCHAIN_PREFIX riscv32-unknown-elf-)

set(CMAKE_SYSTEM_NAME Generic)
set(CMAKE_SYSTEM_PROCESSOR riscv)
set(CMAKE_CROSSCOMPILING 1)
set(CMAKE_CXX_COMPILER ${TOOLCHAIN_BIN}/${TOOLCHAIN_PREFIX}g++)
set(CMAKE_C_COMPILER ${TOOLCHAIN_BIN}/${TOOLCHAIN_PREFIX}gcc)
set(CMAKE_ASM_COMPILER ${TOOLCHAIN_BIN}/${TOOLCHAIN_PREFIX}as)
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)
enable_language(ASM C CXX)

find_program(CMD_OBJCOPY
    ${TOOLCHAIN_PREFIX}objcopy
    PATH ${TOOLCHAIN_BIN}
)    

find_program(CMD_OBJDUMP
    ${TOOLCHAIN_PREFIX}objdump
    PATH ${TOOLCHAIN_BIN}
)    

find_program(CMD_SIZE
    ${TOOLCHAIN_PREFIX}size
    PATH ${TOOLCHAIN_BIN}
)    


message("------------------------------------------------------------")
message("  Toochain configuration file: ${CMAKE_TOOLCHAIN_FILE}")
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

