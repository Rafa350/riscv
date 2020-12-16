#include "RISCV.h"
#include "RISCVMemory.h"


#include <stdlib.h>
#include <string.h>
#include <stdio.h>


#if !defined(RISCV_ENDIAN_BIG) && !defined(RISCV_ENDIAN_LITTLE)
#error No s'ha especificat l'ordre del bytes. Cal definir RISC_ENDIAN_LITTLE o RISC_ENDIAN_BIG
#endif


using namespace RISCV;


/// ----------------------------------------------------------------------
/// \brief    Constructor
/// \param    mem: Buffer de memoria. Si es null crea un inicialitzat a zero
/// \param    memBase: Adressa base de la memoria.
/// \param    memSize: Tamany de la memoria en bytes.
///
Memory::Memory(
    uint8_t *memPtr,
    unsigned memBase,
    unsigned memSize):

    mem(memPtr),
    base(memBase),
    size(memSize),
    allocated(false) {

    if (mem == nullptr) {
        mem = (uint8_t*) malloc(size);
        memset(mem, 0, size);
        allocated = true;
    }
}


/// ----------------------------------------------------------------------
/// \brief    Destructor.
///
Memory::~Memory() {

    if (mem && allocated)
        free(mem);
}


/// ----------------------------------------------------------------------
/// \brief    Llegeix una paraula de 32 bits.
/// \param    addr: Adressa del primer byte de la paraula.
/// \return   La paraula lleigida.
///
data_t Memory::read32(
    addr_t addr) const {

    addr -= base;

    if ((addr + 4) > size)
        return 0;

#if defined(RISCV_ENDIAN_BIG)
    return
        (data_t(mem[addr + 0]) << 24) |
        (data_t(mem[addr + 1]) << 16) |
        (data_t(mem[addr + 2]) <<  8) |
        (data_t(mem[addr + 3]) <<  0);

#elif defined(RISCV_ENDIAN_LITTLE)
    return
        (data_t(mem[addr + 0]) <<  0) |
        (data_t(mem[addr + 1]) <<  8) |
        (data_t(mem[addr + 2]) << 16) |
        (data_t(mem[addr + 3]) << 24);
#else
    #error Undefined ENDIAN type
#endif
}


/// ----------------------------------------------------------------------
/// \brief    Llegeix una paraula de 16 bits.
/// \param    addr: Adressa del primer byte de la paraula.
/// \return   La paraula lleigida.
///
data_t Memory::read16(
    addr_t addr) const {

    addr -= base;

    if (addr + 2 > size)
        return 0;

#if defined(RISCV_ENDIAN_BIG)
    return
        (data_t(mem[addr + 2]) << 8) |
        (data_t(mem[addr + 3]) << 0);

#elif defined(RISCV_ENDIAN_LITTLE)
    return
        (data_t(mem[addr + 0]) << 0) |
        (data_t(mem[addr + 1]) << 8);
#else
    #error Undefined ENDIAN type
#endif
}


/// ----------------------------------------------------------------------
/// \brief    Llegeix una paraula de 8 bits.
/// \param    addr: Adressa del primer byte de la paraula.
/// \return   La paraula lleigida.
///
data_t Memory::read8(
    addr_t addr) const {

    addr -= base;

    if (addr + 1 > size)
        return 0;

    return (data_t) mem[addr];
}


/// ----------------------------------------------------------------------
/// \brief     Escriu una paraula de 32 bits.
/// \param     addr: Adressa del primer byte de la paraula.
/// \param     data: La paramula a escriure.
///
void Memory::write32(
    addr_t addr,
    data_t data) {

    addr -= base;

    if ((addr + 4) > size)
        return;

#if defined(RISCV_ENDIAN_BIG)
    mem[addr + 0] = uint8_t(data >> 24);
    mem[addr + 1] = uint8_t(data >> 16);
    mem[addr + 2] = uint8_t(data >>  8);
    mem[addr + 3] = uint8_t(data >>  0);

#elif defined(RISCV_ENDIAN_LITTLE)
    mem[addr + 0] = uint8_t(data >>  0);
    mem[addr + 1] = uint8_t(data >>  8);
    mem[addr + 2] = uint8_t(data >> 16);
    mem[addr + 3] = uint8_t(data >> 24);

#else
#error UNDEFINED endian TYPE
#endif
}


/// ----------------------------------------------------------------------
/// \brief     Escriu una paraula de 16 bits.
/// \param     addr: Adressa del primer byte de la paraula.
/// \param     data: La paramula a escriure.
///
void Memory::write16(
    addr_t addr,
    data_t data) {

    addr -= base;

    if ((addr + 2) > size)
        return;

#if defined(RISCV_ENDIAN_BIG)
    mem[addr + 0] = uint8_t(data >>  8);
    mem[addr + 1] = uint8_t(data >>  0);

#elif defined(RISCV_ENDIAN_LITTLE)
    mem[addr + 0] = uint8_t(data >>  0);
    mem[addr + 1] = uint8_t(data >>  8);

#else
#error UNDEFINED endian TYPE
#endif
}


/// ----------------------------------------------------------------------
/// \brief    Escriu una paraula de 8 bits.
/// \param    addr: Adressa del primer byte de la paraula.
/// \param    data: La paraula a escriure.
///
void Memory::write8(
    addr_t addr,
    data_t data) {

    addr -= base;

    if (addr + 1 > size)
        return;

    mem[addr] = data;
}


/// ----------------------------------------------------------------------
/// \brief    Relitza un llistat de memoria
/// \param    addr: Adressa inicial.
/// \param    size: El nombre de bites a llistar
///
void Memory::dump(
    addr_t addr,
    unsigned length) const {

    addr -= base;

    if (length > size)
        length = size;

    printf("           0  1  2  3  4  5  6  7  8  9  A  B  C  D  E  F\n");

    while (length) {
        printf("%8.8X: ", addr);
        for (unsigned col = 16; col && length; col--, length--)
            printf("%2.2X ", mem[addr++]);
        printf("\n");
    }

    printf("\n");
}


/// ----------------------------------------------------------------------
/// \brief    Carrega la memoria amb un fitxer en format verilog.
/// \param    fileName: El mon del fitxer.
///
void Memory::load(
    const char *fileName,
    unsigned length) {

    FILE *f = fopen(fileName, "rb");

    if (f == nullptr)
        printf("File '%s', not found.\n", fileName);

    else {


        fclose(f);
    }
}
