cmake_minimum_required(VERSION 3.16.3)
project("firmware")


set(TOOLCHAIN_BIN /opt/riscv32/bin)
set(TOOLCHAIN_PREFIX riscv32-unknown-elf-)

set(CMAKE_SYSTEM_NAME Generic)
set(CMAKE_SYSTEM_PROCESSOR riscv)
set(CMAKE_CROSSCOMPILING 1)
set(CMAKE_CXX_COMPILER ${TOOLCHAIN_BIN}/${TOOLCHAIN_PREFIX}g++)
set(CMAKE_C_COMPILER ${TOOLCHAIN_BIN}/${TOOLCHAIN_PREFIX}gcc)
set(CMAKE_ASM_COMPILER ${TOOLCHAIN_BIN}/${TOOLCHAIN_PREFIX}gcc)
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)


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


set_source_files_properties(
    crt0.S PROPERTIES LANGUAGE C)


# Mostra la configuracio actual
message("* ------------------------------------------------------------------------------------")
message("* Sub-project '${PROJECT_NAME}' configuration.")
message("*   Toochain:")
message("*     gcc     : " ${CMAKE_C_COMPILER})
message("*     g++     : " ${CMAKE_CXX_COMPILER})
message("*     as      : " ${CMAKE_ASM_COMPILER})
message("*     objcopy : " ${CMD_OBJCOPY})
message("*     objdump : " ${CMD_OBJDUMP})
message("*     size    : " ${CMD_SIZE})
message("*")
message("*   Directories:")
message("*     Root    : " ${PROJECT_DIR})
message("*     Current : " ${CMAKE_CURRENT_SOURCE_DIR})
message("*")


# Genera l'executable en format elf
add_executable(
    main.elf)
target_sources(
    main.elf
    PRIVATE crt0.S main.c)
target_compile_options(
    main.elf
    PRIVATE -Wall
            -march=rv32i -mabi=ilp32
            -static -mcmodel=medany
            -ffreestanding -ffunction-sections -fdata-sections
            -Wl,--gc-sections -Wl,--print-gc-sections)
target_link_options(
    main.elf
    PRIVATE -T ${CMAKE_CURRENT_SOURCE_DIR}/link.ld
            -nostdlib -e _start)


# Genera el llistat desensamblat a partir del fitxer elf
add_custom_command(
    TARGET main.elf
    POST_BUILD
    COMMAND ${CMD_OBJDUMP}
    ARGS -M no-aliases -j .text -j .bss -t -d main.elf > firmware.lst)


# Genera el llistat de memoria en format verilog
add_custom_command(
    TARGET main.elf
    POST_BUILD
    COMMAND ${CMD_OBJCOPY}
    ARGS --output-target=verilog
         --verilog-data-width=4
         --only-section=.text
         main.elf firmware.txt)

# Instalacio en la carpeta Run
install(
    FILES ${CMAKE_CURRENT_BINARY_DIR}/firmware.txt
          ${CMAKE_CURRENT_BINARY_DIR}/firmware.lst
    DESTINATION ${PROJECT_DIR}/Run)
