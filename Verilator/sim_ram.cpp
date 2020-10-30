#include "sim.h"


static unsigned data[100];


RAM::RAM() {
    
    mem = data;
    memSize = sizeof(data) / sizeof(data[0]);
    
    for (unsigned i = 0; i < memSize; i++)
        data[i] = 0xAA00 + i;    
}


unsigned RAM::read(
    unsigned addr) const {
    
    if ((mem == NULL) || (addr >= memSize))
        return 0;

    return mem[addr];
}


void RAM::write(
    unsigned addr, 
    unsigned data) {

    if ((mem == NULL) || (addr >= memSize))
        return;
    
    mem[addr] = data;        
}

