#include "sim.h"


#define OpCode_AUIPC  0x17
#define OpCode_Load   0x03
#define OpCode_Store  0x23
#define OpCode_Op     0x33
#define OpCode_LUI    0x37
#define OpCode_OpIMM  0x13
#define OpCode_JAL    0x6F
#define OpCode_Branch 0x63


void TraceInstruction(
    int addr,
    int data) {

    printInstruction(unsigned(addr), uint32_t(data));
}


void TraceRegister(
    int addr,
    int data) {

    printRegister(unsigned(addr), uint32_t(data));
}


void TraceMemory(
    int addr, 
    int data) {
}


/// ----------------------------------------------------------------------
/// \brief    Obte el nom del registre.
/// \param    addr: Adressa del registre.
/// \return   
static const char* getRegName(
    uint32_t regAddr) {
        
    switch (regAddr) {
        case 0: return "zero";
        case 1: return "ra";
        case 2: return "sp";
        case 3: return "gp";
        case 4: return "tp";
        case 5: return "t0";
        case 6: return "t1";
        case 7: return "t2";
        case 8: return "s0";
        case 9: return "s1";
        case 10: return "a0";
        case 11: return "a1";
        case 12: return "a2";
        case 13: return "a3";
        case 14: return "a4";
        case 15: return "a5";
        case 16: return "a6";
        case 17: return "a7";
        case 18: return "s2";
        case 19: return "s3";
        case 20: return "s4";
        case 21: return "s5";
        case 22: return "s6";
        case 23: return "s7";
        case 24: return "s8";
        case 25: return "s9";
        case 26: return "s10";
        case 27: return "s11";
        case 28: return "t3";
        case 29: return "t4";
        case 30: return "t5";
        case 31: return "t6";        
        default: return "X?";
    }
}


void printMemory(
    unsigned addr,
    uint32_t data) {
    
    printf("M: %8.8X := %8.8X\n", addr, data);
}


/// ----------------------------------------------------------------------
/// \brief    Imprimeix informacio d'un registre.
/// \param    addr: L'adressa del registre.
/// \param    data: El contingut del registre.
///
void printRegister(
    unsigned addr,
    uint32_t data) {
        
    const char *r = getRegName(addr);

    printf("R: %s := %8.8X\n", r, data);
}


/// ---------------------------------------------------------------------------
/// \brief    Imprimeix informacio d'una instruccio.
/// \param    addr: L'adressa de la instruccio.
/// \param    data: Codi de la instruccio.
///
void printInstruction(
    unsigned addr,
    uint32_t data) {

    unsigned op  = data & 0x7F;
    unsigned fn3 = (data >> 12) & 0x07;
    unsigned fn7 = (data >> 25) & 0x7F;
    const char *rs1 = getRegName((data >> 15) & 0x1F);
    const char *rs2 = getRegName((data >> 20) & 0x1F);
    const char *rd  = getRegName((data >> 7) & 0x1F);

    printf("I: %8.8X  %8.8X:  ", addr, data);

    switch (op) {
        case OpCode_Op: {
            switch (fn3) {
                case 0b000:
                    if (fn7 & 0b0100000)
                        printf("sub ");
                    else
                        printf("add ");
                    break;

                case 0b001:
                    printf("sll ");
                    break;

                case 0b010:
                    printf("slt ");
                    break;

                case 0b011:
                    printf("sltu");
                    break;

                case 0b100:
                    printf("xor ");
                    break;

                case 0b101:
                    if (fn7 & 0b0100000)
                        printf("sla ");
                    else
                        printf("srr ");
                    break;

                case 0b110:
                    printf("or  ");
                    break;

                case 0b111:
                    printf("and ");
                    break;
            }
            printf("  %s, %s, %s", rd, rs1, rs2);
            break;
        }

        case OpCode_OpIMM: {
            switch (fn3) {
                case 0b000:
                    printf("addi  ");
                break;
            }
            uint32_t imm = 
                ((data >> 20) & 0x00000FFF) |
                ((data & 0x80000000) ? 0xFFFFF000 : 0);
            printf("%s, %s, %8.8X", rd, rs1, imm);
            break;
        }


        case OpCode_Load: {
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
            printf("    %s, %8.8X(%s)", rd, offset, rs1);
            break;
        }

        case OpCode_Store: {
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
            printf("    %s, %8.8X(%s)", rs2, offset, rs1);
            break;
        }
        
        case OpCode_AUIPC: {
            uint32_t imm = 
                ((data & 0xFFFFF000) >> 12);
            printf("auipc %s, %8.8X", rd, imm);
            break;
        }

        case OpCode_LUI: {
            uint32_t imm = 
                ((data & 0xFFFFF000) >> 12) |
                ((data & 0x80000000) ? 0xFFFFF000 : 0);
            printf("lui  %s, %8.8X", rd, imm);
            break;
        }

        case OpCode_JAL: {
            uint32_t offset =
                (((data >> 21) & 0x000003FF) << 1) |
                (((data >> 20) & 0x00000001) << 11) |
                (((data >> 12) & 0x000000FF) << 12) |
                ((data & 0x80000000) ? 0xFFF00000 : 0);
            printf("jal   %s, %8.8X", rd, addr + offset);
            break;
        }

        case OpCode_Branch: {
            switch (fn3) {
                case 0b000:
                    printf("beq ");
                    break;

                case 0b001:
                    printf("bne ");
                    break;

                case 0b100:
                    printf("blt ");
                    break;

                case 0b101:
                    printf("bge ");
                    break;

                case 0b110:
                    printf("bltu");
                    break;

                case 0b111:
                    printf("bgeu");
                    break;
            }
            uint32_t offset =
                (((data >> 7) & 0x00000001) << 11) |
                (((data >> 8) & 0x0000000F) << 1) |
                (((data >> 25) & 0x0000003F) << 5) |
                ((data & 0x80000000) ? 0xFFFFF000 : 0);
            printf("  %s, %s, %8.8X", rs1, rs2, addr + offset);
            break;
        }
    }

    printf("\n");
}