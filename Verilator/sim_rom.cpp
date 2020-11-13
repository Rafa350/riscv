#include "sim.h"


static uint8_t data[] = {
    /* 00 */ 0x83, 0x20, 0x00, 0x00,     // lw   x1, 00000000(x0)
    /* 04 */ 0x03, 0x21, 0x40, 0x00,     // lw   x2, 00000004(x0)
    /* 08 */ 0xB3, 0x81, 0x20, 0x00,     // add  x3, x1, x2   
    /* 0C */ 0x23, 0x24, 0x30, 0x00,     // sw   x3, 00000002(z0)
    /* 10 */ 0x6F, 0xF0, 0x9F, 0xFF,     // jal  x0, FFFFFFF8
};


ROM::ROM():
    Simulation::Memory(data, sizeof(data) / sizeof(data[0])) {
    
}
