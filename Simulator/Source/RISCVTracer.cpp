#include "RISCV.h"
#include "RISCVTracer.h"


#include <stdio.h>


using namespace RISCV;


static const char* getRegName(uint32_t reg);
//static const char* getFpRegName(uint32_t reg);


/// ----------------------------------------------------------------------
/// \brieg    Constructor.
///
Tracer::Tracer() {

}


/// ----------------------------------------------------------------------
/// \brief    presenta la instruccio desensablada.
/// \param    addr: L'adressa.
/// \param    inst: La instruccio.
///
void Tracer::traceInst(
    addr_t addr,
    inst_t inst) {

    unsigned op  = inst & 0x7F;
    unsigned fn3 = (inst >> 12) & 0x07;
    unsigned fn7 = (inst >> 25) & 0x7F;
    const char *name = "???";
    const char *rs1 = getRegName((inst >> 15) & 0x1F);
    const char *rs2 = getRegName((inst >> 20) & 0x1F);
    const char *rd  = getRegName((inst >> 7) & 0x1F);

    printf("I: %8.8X  %8.8X:  ", addr, inst);

    switch (OpCode(op)) {
        case OpCode::Op: {
            switch (fn3) {
                case 0b000:
                    if (fn7 & 0b0100000)
                        name = "sub ";
                    else
                        name = "add ";
                    break;

                case 0b001:
                    name = "sll ";
                    break;

                case 0b010:
                    name = "slt ";
                    break;

                case 0b011:
                    name = "sltu";
                    break;

                case 0b100:
                    name = "xor ";
                    break;

                case 0b101:
                    if (fn7 & 0b0100000)
                        name = "sla ";
                    else
                        name = "srr ";
                    break;

                case 0b110:
                    name = "or  ";
                    break;

                case 0b111:
                    name = "and ";
                    break;
            }
            printf("%s  %s, %s, %s", name, rd, rs1, rs2);
            break;
        }

        case OpCode::OpIMM: {
            switch (fn3) {
                case 0b000:
                    name = "addi";
                    break;

                case 0b100:
                    name = "xori";
                    break;

                case 0b110:
                    name = "ori ";
                    break;

                case 0b111:
                    name = "andi";
                    break;
            }
            data_t imm =
                ((inst >> 20) & 0x00000FFF) |
                ((inst & 0x80000000) ? 0xFFFFF000 : 0);
            printf("%s  %s, %s, %8.8X", name, rd, rs1, imm);
            break;
        }


        case OpCode::Load: {
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
            data_t offset =
                ((inst >> 20) & 0x00000FFF) |
                ((inst & 0x80000000) ? 0xFFFFF000 : 0);

            printf("    %s, %8.8X(%s)", rd, offset, rs1);
            break;
        }

        case OpCode::Store: {
            switch (fn3) {
                case 0b000:
                    printf("sb");
                    break;

                case 0b001:
                    printf("sh");
                    break;

                case 0b010:
                    printf("sw");
                    break;
            }
            data_t offset =
                (((inst & 0xFE000000) >> 25) << 5) |
                ((inst & 0x00000F80) >> 7) |
                ((inst & 0x80000000) ? 0xFFFFF000 : 0);
            printf("    %s, %8.8X(%s)", rs2, offset, rs1);
            break;
        }

        case OpCode::Branch: {
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
                (((inst >> 7) & 0x00000001) << 11) |
                (((inst >> 8) & 0x0000000F) << 1) |
                (((inst >> 25) & 0x0000003F) << 5) |
                ((inst & 0x80000000) ? 0xFFFFF000 : 0);
            printf("  %s, %s, %8.8X  <%8.8X>", rs1, rs2, offset, addr + offset);
            break;
        }

        case OpCode::System:
            break;

        case OpCode::AUIPC: {
            data_t imm =
                ((inst & 0xFFFFF000) >> 12) |
                ((inst & 0x80000000) ? 0xFFFFF000 : 0);
            printf("auipc %s, %8.8X", rd, imm);
            break;
        }

        case OpCode::LUI: {
            uint32_t imm =
                ((inst & 0xFFFFF000) >> 12) |
                ((inst & 0x80000000) ? 0xFFFFF000 : 0);
            printf("lui  %s, %8.8X", rd, imm);
            break;
        }

        case OpCode::JAL: {
            uint32_t offset =
                (((inst >> 21) & 0x000003FF) << 1) |
                (((inst >> 20) & 0x00000001) << 11) |
                (((inst >> 12) & 0x000000FF) << 12) |
                ((inst & 0x80000000) ? 0xFFF00000 : 0);
            printf("jal   %s, %8.8X  <%8.8X>", rd, offset, addr + offset);
            break;
        }

        case OpCode::JALR: {
            uint32_t offset =
                ((inst >> 20) & 0x00000FFF) |
                ((inst & 0x80000000) ? 0xFFFFF000 : 0);
            printf("jalr   %s, %8.8X(%s)", rd, offset, rs1);
            break;
        }
    }

    printf("\n");
}


/// ----------------------------------------------------------------------
/// \brief    Presenta el valor de tick.
/// \param    tick: El valor de tick.
///
void Tracer::traceTick(
    unsigned tick) {

    printf("T: %d\n", tick);
}


/// ----------------------------------------------------------------------
/// \brief    Presenta un registre i el seu valor.
/// \param    reg: El registre. Si es zero, no el mostra.
/// \param    data: El valor del registre
///
void Tracer::traceReg(
    reg_t reg,
    data_t data) {

    if (reg) {
        const char *regName = getRegName(reg);

        printf("R: %s: %8.8X  (%d)\n", regName, data, data);
    }
}


void Tracer::traceMem(
    addr_t addr,
    data_t data) {

    printf("M: %8.8X: %8.8X  (%d)\n", addr, data, data);
}


/// ----------------------------------------------------------------------
/// \brief    Obte el nom del registre.
/// \param    addr: Adressa del registre.
/// \return
static const char* getRegName(
    reg_t regAddr) {

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


/*static const char* getFpRegName(
    reg_t regAddr) {

    return "fpX";
}*/