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
/// \brief    Escriu en la memoria
/// \param    memObj: L'objecte Memory
/// \param    addr: Adressa de memoria
/// \param    mask: Mascara de bytes a escriure
/// \param    data: Les dades a escriure
///
extern "C" void dpiMemWrite(
    const long long memObj,
    int addr,
    int mask,
    int data) {

    Memory *mem = (Memory*) memObj;
    if (mem != nullptr) {
        if (mask == 0b1111)
            mem->write32(unsigned(addr), unsigned(data));

        else if (mask == 0b0011)
            mem->write16(unsigned(addr + 0), unsigned(data));

        else if (mask == 0b1100)
            mem->write16(unsigned(addr + 1), unsigned(data));

        else {
            if (mask == 0b0001)
                mem->write8(unsigned(addr + 0), unsigned(data));

            if (mask == 0b0010)
                mem->write8(unsigned(addr + 1), unsigned(data) >> 8);

            if (mask == 0b0100)
                mem->write8(unsigned(addr + 2), unsigned(data) >> 16);

            if (mask == 0b1000)
                mem->write8(unsigned(addr + 3), unsigned(data) >> 24);
        }
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

    Memory *mem = (Memory*) memObj;
    if (mem != nullptr)
        return mem->read32(unsigned(addr));
    else
        return 0;
}