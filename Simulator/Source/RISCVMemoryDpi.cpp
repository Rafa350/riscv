#include "RISCV.h"
#include "RISCVMemory.h"


using namespace RISCV;


static Memory *memory = nullptr;


/// ----------------------------------------------------------------------
/// \brief    Obte un objecte Memory
/// \return   L'objecte
///
static Memory *getMemory() {

    if (memory == nullptr)
        memory = new Memory(nullptr, RISCV_DMEM_BASE, RISCV_DMEM_SIZE);
    return memory;
}


extern "C" void dpiMemWrite32(
    int addr,
    int data) {

    Memory *memory = getMemory();
    memory->write32(unsigned(addr), unsigned(data));
}
