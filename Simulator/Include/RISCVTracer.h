#pragma once
#ifndef __RISCVTracer__
#define __RISCVTracer__


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


extern "C" {
    void dpiTraceTick(int tick);
    void dpiTraceInstruction(int addr, int data);
    void dpiTraceRegister(int addr, int data);
    void dpiTraceMemory(int addr, int data);
}


#endif // __RISCVTracer__
