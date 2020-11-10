#include "sim.h"


void disassembly(unsigned addr, unsigned data) {

    unsigned op = (data >> 26) & 0x0000003F;   
    unsigned fn = data & 0x0000003F;
    unsigned rs = (data >> 21) & 0x0000001F;
    unsigned rt = (data >> 16) & 0x0000001F;
    unsigned rd = (data >> 11) & 0x0000001F;
    unsigned imm = data & 0x0000FFFF;
    unsigned addr26 = data & 0x03FFFFFF;
    
    VL_PRINTF("%8.8X  %8.8X:  ", addr, data);
    
    if (data) {
        switch (op) {
            case 0b000000: {
                switch (fn) {
                    case 0b100000:
                        VL_PRINTF("add   ");
                        break;

                    case 0b100001:
                        VL_PRINTF("addu  ");
                        break;

                    case 0b100100:
                        VL_PRINTF("and   ");
                        break;
                }
                VL_PRINTF("$%d, $%d, $%d", rd, rs, rt);
                break;
            }
                
            case 0b100011:
                VL_PRINTF("lw    $%d, %d($%d)", rt, imm, rs);
                break;

            case 0b101011:
                VL_PRINTF("sw    $%d, %d($%d)", rt, imm, rs);
                break;
                
            case 0b000010:
                VL_PRINTF("j     %8.8X", addr26);
                break;
        }
    }
    else
        VL_PRINTF("nop");
    
    VL_PRINTF("\n");
}