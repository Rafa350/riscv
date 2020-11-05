#include "sim.h"


#if !defined(BIG_ENDIAN) && !defined(LITLE_ENDIAN)
#error No s'ha especificat l'ordre del bytes. Cal definir LITLE_ENDIAN o BIG_ENDIAN
#endif


static uint8_t data[1024];        // La regio de memoria en bytes


/// ----------------------------------------------------------------------
/// \brief    Constructor
///
RAM::RAM() {
    
    mem = data;
    size = sizeof(data) / sizeof(data[0]);

    for (unsigned i = 0; i < size; i++)
        mem[i] = uint8_t(i);
}


/// ----------------------------------------------------------------------
/// \brief    Llegeix una paraula de 32 bits.
/// \param    addr: Adressa del primer byte de la paraula.
/// \return   La paraula lleigida.
///
uint32_t RAM::read32(
    uint32_t addr) const {
    
    if ((addr + 4) >= size)
        return 0;

#if defined(BIG_ENDIAN)
    return 
        (uint32_t(mem[addr + 0]) << 24) |
        (uint32_t(mem[addr + 1]) << 16) |
        (uint32_t(mem[addr + 2]) <<  8) |
        (uint32_t(mem[addr + 3]) <<  0);
        
#elif defined(LITLE_ENDIAN)
#error No implementat
#endif        
}


/// ----------------------------------------------------------------------
/// \brief    Llegeix una paraula de 8 bits.
/// \param    addr: Adressa del primer byte de la paraula.
/// \return   La paraula lleigida.
///
uint8_t RAM::read8(
    uint32_t addr) const {

    if (addr >= size)
        return 0;

    return mem[addr];
}


/// ----------------------------------------------------------------------
/// \brief     Escriu una paraula de 32 bits.
/// \param     addr: Adressa del primer byte de la paraula.
/// \param     data: La paramula a escriure.
///
void RAM::write32(
    uint32_t addr, 
    uint32_t data) {

    if ((addr + 4) >= size)
        return;
    
#if defined(BIG_ENDIAN)
    mem[addr + 0] = uint8_t(data >> 24);        
    mem[addr + 1] = uint8_t(data >> 16);        
    mem[addr + 2] = uint8_t(data >>  8);        
    mem[addr + 3] = uint8_t(data >>  0);        

#elif defined(LITLE_ENDIAN)
#error No implementat
#endif
}


void RAM::dump(
    uint32_t addr, 
    unsigned size) const {
    
    if (size > this->size)
        size = this->size;
    while (size) {
        VL_PRINTF("%8.8X:  ", addr);
        for (unsigned i = 0; i < 16 && size--; i++) {
            VL_PRINTF("%2.2X  ", mem[addr++]);
            if (!size)
                break;
        }
        VL_PRINTF("\n");
    }
}
