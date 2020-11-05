#include "sim.h"



#if !defined(BIG_ENDIAN) && !defined(LITLE_ENDIAN)
#error No s'ha especificat l'ordre del bytes. Cal definir LITLE_ENDIAN o BIG_ENDIAN
#endif


static uint32_t data[] = {
    /*  0 */ 0x8C010000,     // lw   $1, 0($0)
    /*  1 */ 0x8C020004,     // lw   $2, 1($0)
    /*  2 */ 0x00221820,     // add  $3, $1, $2   
    /*  3 */ 0xAC030008,     // sw   $3, 2($0)
    /*  4 */ 0x08000000,     // J    0 
};


ROM::ROM() {
    
    mem = data;
    size = 4 * sizeof(data) / sizeof(data[0]);
}


ROM::ROM(
    const char *fileName) {
    
    mem = NULL;
    size = 0;
}


uint32_t ROM::read32(
    uint32_t addr) const {
    
    if ((mem == NULL) || (addr >= size))
        return 0;

    return mem[addr >> 2];
}


void ROM::dump(
    uint32_t addr, 
    unsigned size) {
    
    if (size > this->size)
        size = this->size;
    while (size) {
        VL_PRINTF("%8.8X:  ", addr);
        for (unsigned i = 0; i < 4 && size--; i++) {
            VL_PRINTF("%8.8X  ", mem[addr++]);
            if (!size)
                break;
        }
        VL_PRINTF("\n");
    }
}