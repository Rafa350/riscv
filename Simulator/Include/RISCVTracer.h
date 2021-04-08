#pragma once
#ifndef __RISCVTracer__
#define __RISCVTracer__


#include "RISCV.h"
#include <stdint.h>


namespace RISCV {

    class Tracer;

    class TracerInfo {
        private:
            int tick;
            addr_t pc;
            inst_t inst;
            bool traceRegEnabled;
            bool traceMemEnabled;
            gpr_t reg;
            data_t regValue;
            addr_t mem;
            data_t memValue;
            int memAccess;

        public:
            TracerInfo(int tick, addr_t pc, inst_t inst);

            void traceReg(gpr_t reg, data_t value);
            void traceMem(addr_t mem, data_t value, int access);

            void trace(const Tracer *tracer) const;
    };


    class Tracer {
        public:
            Tracer();

            void traceInst(addr_t addr, inst_t inst) const;
            void traceReg(gpr_t reg, data_t data) const;
            void traceMem(addr_t addr, data_t data, int access) const;
            void traceTick(unsigned tick) const;
            void traceString(const char *str) const;
    };

}


extern "C" {
    int dpiTraceCreate(long long *tracerObj);
    int dpiTraceDestroy(const long long tracerObj);
    void dpiTraceTick(const long long tracerObj, int tick);
    void dpiTraceInstruction(const long long tracerObj, int addr, int data);
    void dpiTraceRegister(const long long tracerObj, int addr, int data);
    void dpiTraceMemory(const long long tracerObj, int addr, int access, int data);
}


#endif // __RISCVTracer__
