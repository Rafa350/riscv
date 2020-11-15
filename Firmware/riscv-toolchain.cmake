set(CMAKE_SYSTEM_NAME generic)
set(CMAKE_SYSTEM_PROCESSOR RISCV)

set(TOOLCHAIN_BIN /usr/lib)    
set(TOOLCHAIN_PREFIX riscv64-linux-gnu-)    

find_program(CMAKE_C_COMPILER
    NAMES ${TOOLCHAIN_PREFIX}gcc
    PATH ${TOOLCHAIN_BIN}
)    

find_program(CMAKE_CXX_COMPILER
    NAMES ${TOOLCHAIN_PREFIX}g++
    PATH ${TOOLCHAIN_BIN}
)    

find_program(CMAKE_ASM_COMPILER
    NAMES ${TOOLCHAIN_PREFIX}gcc
    PATH ${TOOLCHAIN_BIN}
)    

find_program(CMD_OBJCOPY
    NAMES ${TOOLCHAIN_PREFIX}objcopy
    PATH ${TOOLCHAIN_BIN}
)    


message("--------------------------------------------------")
message("  RISC-V Toolchain")
message("    gcc     - " ${CMAKE_C_COMPILER})
message("    g++     - " ${CMAKE_CXX_COMPILER})
message("    as      - " ${CMAKE_ASM_COMPILER})
message("    objcopy - " ${CMD_OBJCOPY})
message("--------------------------------------------------")

