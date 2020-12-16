#pragma once


#include "RISCV.h"
#include <stdint.h>


namespace RISCV {

    class Tracer {

        public:
            Tracer();

            void traceInst(addr_t addr, inst_t inst);
            void traceReg(reg_t reg, data_t data);
            void traceMem(addr_t addr, data_t data);
            void traceTick(unsigned tick);
    };

}