#pragma once


#include <stdint.h>


class RISCVTracer {

    public:
        RISCVTracer();

        void traceInst(uint32_t addr, uint32_t inst);
        void traceReg(uint32_t reg, uint32_t data);
        void traceMem(uint32_t addr, uint32_t data);
};
