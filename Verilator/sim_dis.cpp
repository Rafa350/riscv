#include "sim.h"


#define OP_LOAD     0x03
#define OP_STORE    0x23
#define OP_OP       0x33
#define OP_IMM      0x13
#define OP_JAL      0x6F
#define OP_BRANCH   0x63


void disassembly(unsigned addr, uint32_t data) {

    unsigned op  = data & 0x7F;
    unsigned fn3 = (data >> 12) & 0x07;
    unsigned fn7 = (data >> 25) & 0x7F;
    unsigned rs1 = (data >> 15) & 0x1F;
    unsigned rs2 = (data >> 20) & 0x1F;
    unsigned rd = (data >> 7) & 0x1F;

    printf("%8.8X  %8.8X:  ", addr, data);

    if (data) {
        switch (op) {
            case OP_OP: {
                switch (fn3) {
                    case 0b000:
                        if (fn7 & 0b0100000)
                            printf("sub   ");
                        else
                            printf("add   ");
                        break;

                    case 0b001:
                        printf("addu  ");
                        break;

                    case 0b100:
                        printf("and   ");
                        break;
                }
                printf("x%d, x%d, x%d", rd, rs1, rs2);
                break;
            }

            case OP_IMM: {
                switch (fn3) {
                    case 0b000:
                        printf("addi  ");
                    break;
                }
                uint32_t imm = (data & 0xFFF00000) >> 20;
                printf("x%d, x%d, %8.8X", rd, rs1, imm);
                break;
            }


            case OP_LOAD: {
                switch (fn3) {
                    case 0b000:
                        printf("lb");
                        break;

                    case 0b001:
                        printf("lh");
                        break;

                    case 0b010:
                        printf("lw");
                        break;

                    case 0b100:
                        printf("lbu");
                        break;

                    case 0b101:
                        printf("lhu");
                        break;

                    default:
                        printf("[%1.1X]", fn3);
                        break;
                }
                uint32_t offset = (data & 0xFFF00000) >> 20;
                printf("    x%d, %d(x%d)", rd, offset, rs1);
                break;
            }

            case OP_STORE: {
                switch (fn3) {
                    case 0b000:
                        printf("sw");
                        break;

                    case 0b001:
                        printf("sh");
                        break;

                    case 0b010:
                        printf("sw");
                        break;
                }
                uint32_t offset =
                        (((data & 0xFE000000) >> 25) << 5) |
                        ((data & 0x00000F80) >> 7);
                printf("    x%d, %d(x%d)", rs2, offset, rs1);
                break;
            }

            case OP_JAL: {
                uint32_t offset =
                    (((data >> 21) & 0x000003FF) << 1) |
                    (((data >> 20) & 0x00000001) << 11) |
                    (((data >> 12) & 0x000000FF) << 12) |
                    ((data & 0x80000000) ? 0xFFF00000 : 0);
                printf("jal   x%d, %8.8X", rd, offset);
                break;
            }
            
            case OP_BRANCH: {
                switch (fn3) {
                    case 0b000: 
                        printf("beq");
                        break;

                    case 0b001:
                        printf("bne");
                        break;
                }
                uint32_t offset =
                    (((data >> 7) & 0x00000001) << 11) |
                    (((data >> 8) & 0x0000000F) << 1) |
                    (((data >> 25) & 0x0000003F) << 5) |
                    ((data & 0x80000000) ? 0xFFFFF000 : 0);
                printf("  x%d, x%d, %8.8X", rs1, rs2, offset);
                break;
            }
                
        }
    }
    else
        printf("nop");

    printf("\n");
}