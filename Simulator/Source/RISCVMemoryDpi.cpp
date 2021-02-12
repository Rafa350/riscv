#include "RISCV.h"
#include "RISCVMemory.h"


using namespace RISCV;


/// ----------------------------------------------------------------------
/// \brief    Crea el objecte Memory
/// \param    base: Adressa base de la memoria
/// \param    size: Tamany de la memoria en bytes
/// \param    memObj: L'objecte creat.
/// \return   Zero si tot es correcte
///
extern "C" int dpiMemCreate(
    int base,
    int size,
    long long *memObj) {

    Memory *mem = new Memory(nullptr, base, size);
    if (mem != nullptr) {
        *memObj = (long long) mem;
        return 0;
    }
    else {
        *memObj = (long long) 0;
        return 1;
    }
}


/// ----------------------------------------------------------------------
/// \brief    Destrueix el objecte.
/// \param    memObj: L'objecte a destruir.
/// \return   Zero si tot es correcte.
///
extern "C" int dpiMemDestroy(
    long long memObj) {

    Memory *mem = (Memory*) memObj;

    if (mem != nullptr) {
        delete mem;
        return 0;
    }
    else
        return 1;
}


/// ----------------------------------------------------------------------
/// \brief    Llegeix dades d'un fitxer en format verilog
/// \param    memObj: L'objecte Memory
/// \param    fileName: El nom del fitxer
/// \return   0 si tot es correcte.
///
extern "C" int dpiMemLoad(
    const long long memObj,
    const char* fileName) {

    Memory *mem = (Memory*) memObj;
    if (mem != nullptr) {
        mem->load(fileName);
        return 0;
    }

    return 1;
}


/// ----------------------------------------------------------------------
/// \brief    Escriu en la memoria
/// \param    memObj: L'objecte Memory
/// \param    addr: Adressa de memoria en bytes
/// \param    data: Les dades a escriure
///
extern "C" void dpiMemWrite8(
    const long long memObj,
    int addr,
    int data) {

    Memory *mem = (Memory*) memObj;
    if (mem != nullptr)
        mem->write8(addr + 0, data);
}


/// ----------------------------------------------------------------------
/// \brief    Escriu en la memoria
/// \param    memObj: L'objecte Memory
/// \param    addr: Adressa de memoria en bytes
/// \param    data: Les dades a escriure
///
extern "C" void dpiMemWrite32(
    const long long memObj,
    int addr,
    int data) {

    Memory *mem = (Memory*) memObj;
    if (mem != nullptr)
        mem->write32(addr_t(addr), data_t(data));
}


/// ----------------------------------------------------------------------
/// \brief    Llegeix del contingut de la memoria.
/// \param    memObj: L'object Memory
/// \param    addr: L'adressa.
/// \return   El valor lleigit
///
extern "C" int dpiMemRead32(
    const long long memObj,
    int addr) {

    Memory *mem = (Memory*) memObj;
    if (mem != nullptr)
        return int(mem->read32(addr_t(addr)));
    else
        return 0;
}
