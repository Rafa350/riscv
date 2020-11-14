#include "sim.h"


#define OP_LOAD     0x03
#define OP_STORE    0x23
#define OP_OP       0x33
#define OP_IMM      0x13
#define OP_JAL      0x6F


void disassembly(unsigned addr, uint32_t data) {

    unsigned op  = data & 0x7F;   
    unsigned fn3 = (data >> 12) & 0x07;
    unsigned fn7 = (data >> 25) & 0x7F;
    unsigned rs1 = (data >> 15) & 0x1F;
    unsigned rs2 = (data >> 20) & 0x1F;
    unsigned rd = (data >> 7) & 0x1F;
    
    VL_PRINTF("%8.8X  %8.8X:  ", addr, data);
    
    if (data) {
        switch (op) {
            case OP_OP: {
                switch (fn3) {
                    case 0b000:
                        if (fn7 & 0b0100000)
                            VL_PRINTF("sub   ");
                        else
                            VL_PRINTF("add   ");
                        break;

                    case 0b001:
                        VL_PRINTF("addu  ");
                        break;

                    case 0b100:
                        VL_PRINTF("and   ");
                        break;
                }
                VL_PRINTF("x%d, x%d, x%d", rd, rs1, rs2);
                break;
            }
            
            case OP_IMM: {
                switch (fn3) {
                    case 0b000:
                        VL_PRINTF("addi  ");
                    break;
                }
                uint32_t imm = (data & 0xFFF00000) >> 20;
                VL_PRINTF("x%d, x%d, %8.8X", rd, rs1, imm);
                break;
            }

                
            case OP_LOAD: {
                switch (fn3) {
                    case 0b000:
                        VL_PRINTF("lb");
                        break;
                        
                    case 0b001:
                        VL_PRINTF("lh");
                        break;
                        
                    case 0b010:
                        VL_PRINTF("lw");
                        break;

                    case 0b100:
                        VL_PRINTF("lbu");
                        break;

                    case 0b101:
                        VL_PRINTF("lhu");
                        break;
                        
                    default:
                        VL_PRINTF("[%1.1X]", fn3);
                        break;
                }
                uint32_t offset = (data & 0xFFF00000) >> 20;
                VL_PRINTF("    x%d, %d(x%d)", rd, offset, rs1);
                break;
            }

            case OP_STORE: {
                switch (fn3) {
                    case 0b000:
                        VL_PRINTF("sw");
                        break;
                        
                    case 0b001:
                        VL_PRINTF("sh");    
                        
                        break;
                        
                    case 0b010:
                        VL_PRINTF("sw");
                        break;
                }
                uint32_t offset = 
                        (((data & 0xFE000000) >> 25) << 5) |
                        ((data & 0x00000F80) >> 7);
                VL_PRINTF("    x%d, %d(x%d)", rs2, offset, rs1);
                break;
            }
                
            case OP_JAL: {
                uint32_t offset =
                    ((data & 0x8000) ? 0xFFF00000 : 0x00000000) | 
                    (((data >> 21) & 0x000003FF) << 1) | 
                    (((data >> 20) & 0x00000001) << 11) |
                    (((data >> 12) & 0x000000FF) << 12);
                VL_PRINTF("jal   x%d, %8.8X", rd, offset);
                break;
            }
        }
    }
    else
        VL_PRINTF("nop");
    
    VL_PRINTF("\n");
}