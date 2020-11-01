#include "sim.h"


static uint32_t data[100];


RAM::RAM() {
    
    mem = data;
    size = sizeof(data) / sizeof(data[0]);
    
    for (unsigned i = 0; i < size; i++)
        data[i] = 0xAA00 + i;    
}


uint32_t RAM::read(
    uint32_t addr) const {
    
    if ((mem == NULL) || (addr >= size))
        return 0;

    return mem[addr];
}

uint8_t RAM::read(
    uint32_t addr,
    unsigned byte) const {

    if ((mem == NULL) || (addr >= size) || (byte >= 4))
        return 0;

    return uint8_t(mem[addr] >> (byte * 8));
}


void RAM::write(
    uint32_t addr, 
    uint32_t data) {

    if ((mem == NULL) || (addr >= size))
        return;
    
    mem[addr] = data;        
}

void RAM::dump(
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
