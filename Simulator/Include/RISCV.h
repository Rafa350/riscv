#pragma once


#include <stdint.h>


#define RISCV_ENDIAN_LITTLE

#define RISCV_DMEM_BASE        0x100000
#define RISCV_DMEM_SIZE        1024

#define RISCV_IMEM_BASE        0x000000
#define RISCV_IMEM_SIZE        256


namespace RISCV {

    enum class OpCode {
        Load    = 0x03,
        Store   = 0x23,
        Op      = 0x33,
        OpIMM   = 0x13,
        Branch  = 0x63,
        System  = 0x73,
        AUIPC   = 0x17,
        JAL     = 0x6F,
        JALR    = 0x67,
        LUI     = 0x37
    };

    typedef uint32_t data_t;
    typedef uint32_t addr_t;
    typedef uint32_t reg_t;
    typedef uint32_t inst_t;

}
