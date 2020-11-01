#include "sim.h"




static uint32_t data[] = {
    /*  0 */ 0x8C010000,     // lw   $1, 0($0)
    /*  1 */ 0x8C020001,     // lw   $2, 1($0)
    /*  2 */ 0x00221820,     // add  $3, $1, $2   
    /*  3 */ 0xAC030002,     // sw   $3, 2($0)
    /*  4 */ 0x08000000,     // J    0 
};


ROM::ROM() {
    
    mem = data;
    size = sizeof(data) / sizeof(data[0]);
}


ROM::ROM(
    const char *fileName) {
    
    mem = NULL;
    size = 0;
}


uint32_t ROM::read(
    uint32_t addr) const {
    
    if ((mem == NULL) || (addr >= size))
        return 0;

    return mem[addr];
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