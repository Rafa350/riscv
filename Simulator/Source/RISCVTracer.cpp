#include "RISCV.h"
#include "RISCVTracer.h"

#include <stdio.h>


using namespace RISCV;


static const char* getGPRegName(gpr_t reg);
static const char* getCSRegName(csr_t reg);
//static const char* getFPRegName(uint32_t reg);


/// ----------------------------------------------------------------------
/// \brieg    Constructor.
///
Tracer::Tracer() {

}


/// ----------------------------------------------------------------------
/// \brief    Presenta la instruccio desensablada.
/// \param    addr: L'adressa.
/// \param    inst: La instruccio.
///
void Tracer::traceInst(
    addr_t addr,
    inst_t inst) const {

    unsigned op  = inst & 0x7F;
    unsigned fn3 = (inst >> 12) & 0x07;
    unsigned fn7 = (inst >> 25) & 0x7F;
    const char *name = "???";
    const char *rs1 = getGPRegName((inst >> 15) & 0x1F);
    const char *rs2 = getGPRegName((inst >> 20) & 0x1F);
    const char *rd  = getGPRegName((inst >> 7) & 0x1F);

    printf("%8.8X: %8.8X     ", addr, inst);

    switch (OpCode(op)) {
        case OpCode::Op: {
            switch (fn3) {
                case 0b000:
                    if (fn7 & 0b0100000)
                        name = "sub";
                    else
                        name = "add";
                    break;

                case 0b001:
                    name = "sll";
                    break;

                case 0b010:
                    name = "slt";
                    break;

                case 0b011:
                    name = "sltu";
                    break;

                case 0b100:
                    name = "xor";
                    break;

                case 0b101:
                    if (fn7 & 0b0100000)
                        name = "sla";
                    else
                        name = "srr";
                    break;

                case 0b110:
                    name = "or";
                    break;

                case 0b111:
                    name = "and";
                    break;
            }
            printf("%s %s, %s, %s", name, rd, rs1, rs2);
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

                case 0b101:
                    name = "srli";
                    break;

                case 0b110:
                    name = "ori";
                    break;

                case 0b111:
                    name = "andi";
                    break;
            }
            data_t imm =
                ((inst >> 20) & 0x00000FFF) |
                ((inst & 0x80000000) ? 0xFFFFF000 : 0);
            printf("%s %s, %s, %8.8X  (%d)", name, rd, rs1, imm, imm);
            break;
        }

        case OpCode::Load: {
            switch (fn3) {
                case 0b000:
                    name = "lb";
                    break;

                case 0b001:
                    name = "lh";
                    break;

                case 0b010:
                    name = "lw";
                    break;

                case 0b100:
                    name = "lbu";
                    break;

                case 0b101:
                    name = "lhu";
                    break;
            }
            data_t offset =
                ((inst >> 20) & 0x00000FFF) |
                ((inst & 0x80000000) ? 0xFFFFF000 : 0);
            printf("%s %s, %8.8X[%s]  (%d)", name, rd, offset, rs1, offset);
            break;
        }

        case OpCode::Store: {
            switch (fn3) {
                case 0b000:
                    name = "sb";
                    break;

                case 0b001:
                    name = "sh";
                    break;

                case 0b010:
                    name = "sw";
                    break;
            }
            data_t offset =
                (((inst & 0xFE000000) >> 25) << 5) |
                ((inst & 0x00000F80) >> 7) |
                ((inst & 0x80000000) ? 0xFFFFF000 : 0);
            printf("%s %s, %8.8X[%s]  (%d)", name, rs2, offset, rs1, offset);
            break;
        }

        case OpCode::Branch: {
            switch (fn3) {
                case 0b000:
                    name = "beq";
                    break;

                case 0b001:
                    name = "bne";
                    break;

                case 0b100:
                    name = "blt";
                    break;

                case 0b101:
                    name = "bge";
                    break;

                case 0b110:
                    name = "bltu";
                    break;

                case 0b111:
                    name = "bgeu";
                    break;
            }
            uint32_t offset =
                (((inst >> 7) & 0x00000001) << 11) |
                (((inst >> 8) & 0x0000000F) << 1) |
                (((inst >> 25) & 0x0000003F) << 5) |
                ((inst & 0x80000000) ? 0xFFFFF000 : 0);
            printf("%s %s, %s, %8.8X  <%8.8X>", name, rs1, rs2, offset, addr + offset);
            break;
        }

        case OpCode::System: {
            if (fn3 != 0b000) {
                switch (fn3) {
                    case 0b001:
                    case 0b101:
                        name = "csrrw";
                        break;

                    case 0b010:
                    case 0b110:
                        name = "csrrs";
                        break;

                    case 0b011:
                    case 0b111:
                        name = "csrrc";
                        break;
                }
                csr_t csr = (inst >> 20) & 0x00000FFF;
                const char* csrName = getCSRegName(csr);
                uint32_t imm = (inst >> 15) & 0x1F;
                if ((fn3 & 0b100) == 0b100)
                    printf("%si %s, %s, %2.2X", name, rd, csrName, imm);
                else
                    printf("%s  %s, %s, %s", name, rd, csrName, rs1);
            }
            break;
        }

        case OpCode::AUIPC: {
            data_t imm =
                ((inst & 0xFFFFF000) >> 12) |
                ((inst & 0x80000000) ? 0xFFFFF000 : 0);
            printf("auipc %s, %8.8X  (%d)", rd, imm, imm);
            break;
        }

        case OpCode::LUI: {
            uint32_t imm =
                ((inst & 0xFFFFF000) >> 12) |
                ((inst & 0x80000000) ? 0xFFFFF000 : 0);
            printf("lui %s, %8.8X  (%d)", rd, imm, imm);
            break;
        }

        case OpCode::JAL: {
            uint32_t offset =
                (((inst >> 21) & 0x000003FF) << 1) |
                (((inst >> 20) & 0x00000001) << 11) |
                (((inst >> 12) & 0x000000FF) << 12) |
                ((inst & 0x80000000) ? 0xFFF00000 : 0);
            printf("jal %s, %8.8X  <%8.8X>", rd, offset, addr + offset);
            break;
        }

        case OpCode::JALR: {
            uint32_t offset =
                ((inst >> 20) & 0x00000FFF) |
                ((inst & 0x80000000) ? 0xFFFFF000 : 0);
            printf("jalr %s, %8.8X[%s]  (%d)", rd, offset, rs1, offset);
            break;
        }
    }
}


/// ----------------------------------------------------------------------
/// \brief    Presenta el valor de tick.
/// \param    tick: El valor de tick.
///
void Tracer::traceTick(
    unsigned tick) const {

    printf("%10.10d", tick);
}


/// ----------------------------------------------------------------------
/// \brief    Presenta acces a registre.
/// \param    reg: El registre. Si es zero, no el mostra.
/// \param    data: El valor del registre
///
void Tracer::traceReg(
    gpr_t reg,
    data_t data) const {

    if (reg) {
        const char *regName = getGPRegName(reg);

        printf("%-3s: %8.8X", regName, data);
    }
}


/// ----------------------------------------------------------------------
/// \brief    Presenta un acces a memoria
/// \param    addr: Adressa de memoria
/// \param    data: El valor.
/// \param    access: El tipus d'acces
///
void Tracer::traceMem(
    addr_t addr,
    data_t data,
    int access) const {

    switch (access) {
        case 0: // Byte
            printf("%8.8X: %2.2X      ", addr, data & 0xFF);
            break;

        case 1: // Half
            printf("%8.8X: %4.4X    ", addr, data & 0xFFFF);
            break;

        case 2: // Word
            printf("%8.8X: %8.8X", addr, data);
            break;
    }
}


/// ----------------------------------------------------------------------
/// \brief    Presenta un text lliure
/// \param    str: El text
///
void Tracer::traceString(
    const char *str) const {

    printf("%s", str);
}


/// ----------------------------------------------------------------------
/// \brief    Obte el nom del registre.
/// \param    reg: Adressa del registre.
/// \return   El nom del registre
///
static const char* getGPRegName(
    gpr_t reg) {

    switch (reg) {
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


/// ----------------------------------------------------------------------
/// \brief    Obte el nom d'un registre CSR
/// \param    reg: Adressa del registre
/// \return   El nom del registre
///
static const char* getCSRegName(
    csr_t reg) {

    switch (reg) {
        case 0x300: return "mstatus";
        case 0x301: return "misa";
        case 0x302: return "medeleg";
        case 0x303: return "mideleg";
        case 0x304: return "mie";
        case 0x305: return "mtvec";
        case 0x306: return "mcounteren";
        case 0x320: return "mcountinhibit";
        case 0x340: return "mscratch";
        case 0x341: return "mepc";
        case 0x342: return "mcause";
        case 0x343: return "mtval";
        case 0x344: return "mip";
        case 0xB00: return "mcycle";
        case 0xB02: return "minstret";
        case 0xB03: return "mhpmcounter3";
        case 0xB04: return "mhpmcounter4";
        case 0xB05: return "mhpmcounter5";
        case 0xB06: return "mhpmcounter6";
        case 0xB07: return "mhpmcounter7";
        case 0xB08: return "mhpmcounter8";
        case 0xB09: return "mhpmcounter9";
        case 0x323: return "mhpmevent3";
        case 0x324: return "mhpmevent4";
        case 0x325: return "mhpmevent5";
        case 0x326: return "mhpmevent6";
        case 0x327: return "mhpmevent7";
        case 0x328: return "mhpmevent8";
        case 0x329: return "mhpmevent9";
        default   : return "???";
    }
}



/*static const char* getFPRegName(
    reg_t reg) {

    return "fpX";
}*/