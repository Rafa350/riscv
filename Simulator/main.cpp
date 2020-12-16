#include <iostream>
#include "RISCV.h"
#include "RISCVProcessor.h"
#include "RISCVMemory.h"
#include "RISCVTracer.h"


using namespace std;
using namespace RISCV;


static uint32_t insts[] = {
    0x6F000003, 0x6F008002, 0x6F004002, 0x6F000002,
    0x6F00C001, 0x6F008001, 0x6F004001, 0x6F000001,
    0x6F00C000, 0x6F008000, 0x6F004000, 0x6F000000,
    0x17011000, 0x1301012D, 0xEF008000, 0x6F000000,
    0x130101FE, 0x232E8100, 0x13040102, 0x232604FE,
    0x6F00C001, 0x93070020, 0x0327C4FE, 0x23A0E700,
    0x8327C4FE, 0x93871700, 0x2326F4FE, 0x0327C4FE,
    0x93073000, 0xE3D0E7FE, 0x13000000, 0x13000000,
    0x0324C101, 0x13010102, 0x67800000
};

int main() {

    cout << "RISCV Behavorial simulator V1.0\n";

    Tracer *tracer = new Tracer();
    if (tracer) {

        Memory *dataMem = new Memory(nullptr, 0x100000, 1024);
        if (dataMem) {

            for (unsigned addr = 0; addr < dataMem->getSize(); addr++)
                dataMem->write8(addr, addr);

            Processor *proc = new Processor(tracer, dataMem, nullptr);
            if (proc) {

                for (int i = 0; i < 100; i++) {

                    uint32_t pc = proc->getPC();
                    uint32_t addr = pc >> 2;

                    uint32_t inst =
                        ((insts[addr] & 0xFF000000) >> 24) |
                        ((insts[addr] & 0x00FF0000) >>  8) |
                        ((insts[addr] & 0x0000FF00) <<  8) |
                        ((insts[addr] & 0x000000FF) << 24);

                    proc->execute(inst);
                }

                delete proc;
            }
        }

        delete tracer;
    }

    return 0;
}