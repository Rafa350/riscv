#pragma once


#include "RISCV.h"
#include <stdint.h>


namespace RISCV {

    class Memory;
    class Tracer;


    class Processor {
        private:
            Tracer *tracer;
            Memory *dataMem;
            Memory *instMem;
            uint32_t tick;      // Contador de tics
            addr_t pc;          // Contador de programa
            data_t r[32];       // Registres base
            data_t csr[4096];   // Registres de control

        private:
            void executeLoad(inst_t inst);
            void executeStore(inst_t inst);
            void executeOp(inst_t inst);
            void executeOpIMM(inst_t inst);
            void executeBranch(inst_t inst);
            void executeSystem(inst_t inst);
            void executeAUIPC(inst_t inst);
            void executeJAL(inst_t inst);
            void executeJALR(inst_t inst);
            void executeLUI(inst_t inst);

            inst_t expand(inst_t inst);

            void traceTick();
            void traceInst(inst_t inst);
            void traceReg(gpr_t reg);
            void traceMem(addr_t addr, int access);

        public:
            Processor(Tracer *tracer, Memory *dataMem, Memory *instMem);

            void reset();
            void execute(inst_t inst);

            addr_t getPC() const { return pc; }
    };
}