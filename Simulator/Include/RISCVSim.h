#pragma once


#include <stdint.h>


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


class RISCVTracer;

class RISCVSim {
    private:
        RISCVTracer *tracer;
        uint32_t pc;
        uint32_t r[32];

    private:
        void executeLoad(uint32_t inst);
        void executeStore(uint32_t inst);
        void executeOp(uint32_t inst);
        void executeOpIMM(uint32_t inst);
        void executeBranch(uint32_t inst);
        void executeSystem(uint32_t inst);
        void executeAUIPC(uint32_t inst);
        void executeJAL(uint32_t inst);
        void executeJALR(uint32_t inst);
        void executeLUI(uint32_t inst);

        uint32_t expand(uint32_t inst);

        void traceInst(uint32_t inst);
        void traceReg(uint32_t reg, uint32_t data);
        void traceMem(uint32_t addr, uint32_t data);

    public:
        RISCVSim(RISCVTracer *tracer);

        void reset();
        void execute(uint32_t inst);
};
