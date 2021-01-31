#include "RISCV.h"
#include "RISCVMemory.h"


#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <ctype.h>


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
    addr_t memBase,
    unsigned memSize):

    base(memBase),
    size(memSize),
    allocated(false),
    mem(memPtr) {

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

    if ((mem != nullptr) && allocated)
        free(mem);
}


/// ----------------------------------------------------------------------
/// \brief    Llegeix una paraula de 32 bits.
/// \param    addr: Adressa del primer byte de la paraula.
/// \return   La paraula lleigida.
///
data_t Memory::read32(
    addr_t addr) const {

    addr_t a = addr - base;

    if ((a + 4) > size)
        return 0;

#if defined(RISCV_ENDIAN_BIG)
    return
        (data_t(mem[a + 0]) << 24) |
        (data_t(mem[a + 1]) << 16) |
        (data_t(mem[a + 2]) <<  8) |
        (data_t(mem[a + 3]) <<  0);

#elif defined(RISCV_ENDIAN_LITTLE)
    return
        (data_t(mem[a + 0]) <<  0) |
        (data_t(mem[a + 1]) <<  8) |
        (data_t(mem[a + 2]) << 16) |
        (data_t(mem[a + 3]) << 24);
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

    addr_t a = addr - base;

    if (a + 2 > size)
        return 0;

#if defined(RISCV_ENDIAN_BIG)
    return
        (data_t(mem[a + 2]) << 8) |
        (data_t(mem[a + 3]) << 0);

#elif defined(RISCV_ENDIAN_LITTLE)
    return
        (data_t(mem[a + 0]) << 0) |
        (data_t(mem[a + 1]) << 8);
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

    addr_t a = addr - base;

    if (a + 1 > size)
        return 0;

    return data_t(mem[a]);
}


/// ----------------------------------------------------------------------
/// \brief     Escriu una paraula de 32 bits.
/// \param     addr: Adressa del primer byte de la paraula.
/// \param     data: La paramula a escriure.
///
void Memory::write32(
    addr_t addr,
    data_t data) {

    addr_t a = addr - base;

    if ((a + 4) > size)
        return;

#if defined(RISCV_ENDIAN_BIG)
    mem[a + 0] = uint8_t(data >> 24);
    mem[a + 1] = uint8_t(data >> 16);
    mem[a + 2] = uint8_t(data >>  8);
    mem[a + 3] = uint8_t(data >>  0);

#elif defined(RISCV_ENDIAN_LITTLE)
    mem[a + 0] = uint8_t(data >>  0);
    mem[a + 1] = uint8_t(data >>  8);
    mem[a + 2] = uint8_t(data >> 16);
    mem[a + 3] = uint8_t(data >> 24);

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

    addr_t a = addr - base;

    if ((a + 2) > size)
        return;

#if defined(RISCV_ENDIAN_BIG)
    mem[a + 0] = uint8_t(data >>  8);
    mem[a + 1] = uint8_t(data >>  0);

#elif defined(RISCV_ENDIAN_LITTLE)
    mem[a + 0] = uint8_t(data >>  0);
    mem[a + 1] = uint8_t(data >>  8);

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

    addr_t a = addr - base;

    if (a + 1 > size)
        return;

    mem[a] = data;
}


/// ----------------------------------------------------------------------
/// \brief    Relitza un llistat de memoria
/// \param    addr: Adressa inicial.
/// \param    size: El nombre de bites a llistar
///
void Memory::dump(
    addr_t addr,
    unsigned length) const {

    addr_t a = addr - base;

    if (length > size)
        length = size;

    printf("           0  1  2  3  4  5  6  7  8  9  A  B  C  D  E  F\n");

    while (length) {
        printf("%8.8X: ", a + base);
        for (unsigned col = 16; col && length; col--, length--)
            printf("%2.2X ", mem[a++]);
        printf("\n");
    }

    printf("\n");
}


/// ----------------------------------------------------------------------
/// \brief    Carrega la memoria amb un fitxer en format verilog.
/// \param    fileName: El mon del fitxer.
///
void Memory::load(
    const char *fileName) {

    FILE *f = fopen(fileName, "rb");

    if (f == nullptr)
        printf("File '%s', not found.\n", fileName);

    else {
        char buffer[10];
        unsigned index;
        bool addrMode = false;
        unsigned state = 0;
        addr_t addr = 0;
        while (state != unsigned(-1)) {
            int ch = fgetc(f);
            switch (state) {
                case 0:
                    if (ch == '@') {
                        index = 0;
                        addrMode = true;
                        state = 1;
                    }
                    else if (isxdigit(ch)) {
                        index = 0;
                        buffer[index++] = ch;
                        state = 1;
                    }
                    else if (!isspace(ch))
                        state = -1;
                    break;

                case 1:
                    if (isxdigit(ch)) {
                        if (index < sizeof(buffer) - 1)
                            buffer[index++] = ch;
                    }
                    else {
                        buffer[index] = '\0';
                        if (addrMode) {
                            addr = addr_t(strtoul(buffer, nullptr, 16));
                            addrMode = false;
                        }
                        else {
                            data_t d1 = data_t(strtoul(buffer, nullptr, 16));
                            /*data_t d2 =
                                ((d1 & 0xFF000000) >> 24) |
                                ((d1 & 0x00FF0000) >> 8) |
                                ((d1 & 0x0000FF00) << 8) |
                                ((d1 & 0x000000FF) << 24);*/
                            write32(addr, d1);
                            addr += 4;
                        }

                        state = 0;
                    }
                    break;

                default:
                    state = -1;
                    break;
            }
        }

        fclose(f);
    }
}
