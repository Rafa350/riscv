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
    if (mem) {
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

    if (mem) {
        delete mem;
        return 0;
    }
    else
        return 1;
}


/// ----------------------------------------------------------------------
/// \brief    Escriu en la memoria
/// \param    memObj: L'objecte Memory
/// \param    addr: Adressa de memoris
/// \param    mask: Mascara de bytes a escriure
/// \param    data: Les dades a escriure
///
extern "C" void dpiMemWrite(
    const long long memObj,
    int addr,
    int mask,
    int data) {

    Memory *memory = (Memory*) memObj;

    switch (mask) {
        case 0b1111:
            memory->write32(unsigned(addr), unsigned(data));
            break;

        case 0b0001:
            memory->write8(unsigned(addr), unsigned(data));
            break;

        case 0b0010:
            memory->write8(unsigned(addr), unsigned(data) >> 8);
            break;

        case 0b0100:
            memory->write8(unsigned(addr), unsigned(data) >> 16);
            break;

        case 0b1000:
            memory->write8(unsigned(addr), unsigned(data) >> 24);
            break;
    }
}


/// ----------------------------------------------------------------------
/// \brief    Llegeix del contingut de la memoria.
/// \param    memObj: L'object Memory
/// \param    addr: L'adressa.
/// \return   El valor lleigit
///
extern "C" int dpiMemRead(
    const long long memObj,
    int addr) {

    Memory *memory = (Memory*) memObj;

    return memory->read32(unsigned(addr));
}