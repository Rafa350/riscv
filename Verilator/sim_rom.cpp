#include "sim.h"




static unsigned data[] = {
    /*  0 */ 0b10001100000000010000000000000000,     // LW $1, 0($0)
    /*  1 */ 0b10001100000000100000000000000001,     // LW $12, 1($0)
    /*  2 */ 0b00000000001000100001100000100000,     // ADD $3, $1, $2)
    /*  3 */ 0b10101100000000110000000000000010,     // SW $3, 2($0)
    /*  4 */ 0b00001000000000000000000000000000,     // J 0 
};


ROM::ROM() {
    
    mem = data;
    memSize = sizeof(data) / sizeof(data[0]);
}


ROM::ROM(
    const char *fileName) {
    
    mem = NULL;
    memSize = 0;
}


unsigned ROM::read(
    unsigned addr) const {
    
    if ((mem == NULL) || (addr >= memSize))
        return 0;

    return mem[addr];
}
