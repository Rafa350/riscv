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
    int dpiTraceCreate(long long *tracerObj);
    int dpiTraceDestroy(const long long tracerObj);
    void dpiTraceTick(const long long tracerObj, int tick);
    void dpiTraceInstruction(const long long tracerObj, int addr, int data);
    void dpiTraceRegister(const long long tracerObj, int addr, int data);
    void dpiTraceMemory(const long long tracerObj, int addr, int data);
}


#endif // __RISCVTracer__
