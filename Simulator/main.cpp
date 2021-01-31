#include "RISCV.h"
#include "RISCVProcessor.h"
#include "RISCVMemory.h"
#include "RISCVTracer.h"


#include <stdio.h>


using namespace std;
using namespace RISCV;


int main() {

    printf("RISCV ISS Simulator V1.0\n\n");

    Tracer *tracer = new Tracer();
    if (tracer) {

        Memory *instMem = new Memory(nullptr, RISCV_IMEM_BASE, RISCV_IMEM_SIZE);
        if (instMem) {
            instMem->load("firmware.txt");

            Memory *dataMem = new Memory(nullptr, RISCV_DMEM_BASE, RISCV_DMEM_SIZE);
            if (dataMem) {

                printf("Emulated RAM memory:\n");
                printf("    Base addr     : %8.8X\n", dataMem->getBase());
                printf("    Size in bytes : %-d\n\n", dataMem->getSize());

                Processor *proc = new Processor(tracer, dataMem, nullptr);
                if (proc) {

                    for (int i = 0; i < 2000; i++) {

                        addr_t pc = proc->getPC();
                        inst_t inst = instMem->read32(pc);

                        // Detecta bucle infinit al retornar de main()
                        //
                        if (inst == 0x0000006F)
                            break;

                        proc->execute(inst);
                        printf("\n");
                    }

                    delete proc;
                }

                /*printf("Instruction memory dump:\n");
                instMem->dump(RISCV_IMEM_BASE, 128);
                printf("\n");*/

                printf("Data memory dump:\n");
                dataMem->dump(RISCV_DMEM_BASE, 128);
                printf("\n");

                delete dataMem;
            }
            delete instMem;
        }

        delete tracer;
    }

    return 0;
}