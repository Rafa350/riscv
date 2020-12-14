#include "RISCVSim.h"
#include "RISCVTracer.h"


/// ----------------------------------------------------------------------
/// \brief    Constructor
///
RISCVSim::RISCVSim(
    RISCVTracer *tracer) :
    tracer(tracer) {

    reset();
}


/// ----------------------------------------------------------------------
/// \brief    Reseteja el sistema
///
void RISCVSim::reset() {

    pc = 0;
    for (unsigned i = 0; i < sizeof(r) / sizeof(r[0]); i++)
        r[i] = 0;
}



/// ----------------------------------------------------------------------
/// @brief    Executa una instruccio.
/// @param    inst: La instruccio.
///
void RISCVSim::execute(
    uint32_t inst) {

    if ((inst & 0x3) != 0x3)
        inst = expand(inst);

    switch (OpCode(inst & 0x7F)) {

        case OpCode::AUIPC:
            executeAUIPC(inst);
            break;

        case OpCode::LUI:
            executeLUI(inst);
            break;

        case OpCode::JAL:
            executeJAL(inst);
            break;

        case OpCode::JALR:
            executeJALR(inst);
            break;

        case OpCode::Load:
            executeLoad(inst);
            break;

        case OpCode::Store:
            executeStore(inst);
            break;

        case OpCode::Branch:
            executeBranch(inst);
            break;

        case OpCode::Op:
            executeOp(inst);
            break;

        case OpCode::OpIMM:
            executeOpIMM(inst);
            break;
    }
}


/// ----------------------------------------------------------------------
/// @brief    Executa la instruccio AUIPC
/// @param    inst: La instruccio.
///
void RISCVSim::executeAUIPC(
    uint32_t inst) {

    traceInst(inst);

    unsigned rd = (inst >> 7) & 0x1F;
    uint32_t imm = inst & 0xFFFFF000;

    r[rd] = pc + imm;
    pc += 4;

    traceReg(rd, r[rd]);
}


/// ----------------------------------------------------------------------
/// \brief    Executa la instruccio LUI
/// \param    inst: La instruccio.
///
void RISCVSim::executeLUI(
    uint32_t inst) {

    traceInst(inst);

    unsigned rd = (inst >> 7) & 0x1F;
    uint32_t imm = inst & 0xFFFFF000;

    r[rd] = imm;
    pc += 4;

    traceReg(rd, r[rd]);
}


/// ----------------------------------------------------------------------
/// \brief    Executa la instruccio JAL
/// \param    inst: La instruccio.
///
void RISCVSim::executeJAL(
    uint32_t inst) {

    traceInst(inst);

    unsigned rd = (inst >> 7) & 0x1F;
    uint32_t imm =
        (((inst >> 21) & 0x000003FF) << 1) |
        (((inst >> 20) & 0x00000001) << 11) |
        (((inst >> 12) & 0x000000FF) << 12) |
        ((inst & 0x80000000) ? 0xFFF00000 : 0x00000000);

    r[rd] = pc + 4;
    pc += imm;

    traceReg(rd, r[rd]);
}


/// ----------------------------------------------------------------------
/// \brief    Executa la instruccio JALR
///
void RISCVSim::executeJALR(
    uint32_t inst) {

    traceInst(inst);

    unsigned rd = (inst >> 7) & 0x1F;
    unsigned rs1 = (inst >> 15) & 0x1F;
    uint32_t imm =
        ((inst >> 20) & 1) |
        (inst & 0x80000000 ? 0xFFFFF000 : 0x00000000);

    r[rd] = pc + 4;
    pc = r[rs1] + imm;

    traceReg(rd, r[rd]);
}


/// ----------------------------------------------------------------------
/// \brief    Executa el grup d'insatruccions Op
/// \param    inst: La instruccio.
///
void RISCVSim::executeOp(
    uint32_t inst) {

    traceInst(inst);

    unsigned rd  = (inst >> 7) & 0x1F;
    unsigned rs1 = (inst >> 15) & 0x1F;
    unsigned rs2 = (inst >> 20) & 0x1F;

    uint32_t v = 0;
    switch ((inst >> 25) & 0b1111111) {
        case 0b0000000:
            switch ((inst >> 12) & 0x07) {
                case 0b000: // ADD
                    v = r[rs1] + r[rs2];
                    break;

                case 0b001: //
                    break;

                case 0b010: //
                    break;

                case 0b011: //
                    break;

                case 0b100: // XOR
                    v = r[rs1] ^ r[rs2];
                    break;

                case 0b101: //
                    break;

                case 0b110: // OR
                    v = r[rs1] | r[rs2];
                    break;

                case 0b111: // AND
                    v = r[rs1] & r[rs2];
                    break;
            }
            break;

        case 0b0100000:
            switch ((inst >> 12) & 0b111) {
                case 0b000: // SUB
                    v = r[rs1] - r[rs2];
                    break;

                case 0b101: // SRA
                    break;
            }
            break;
    }


    r[rd] = v;
    pc += 4;

    traceReg(rd, r[rd]);
}


/// ----------------------------------------------------------------------
/// \brief    Executa el grup d'instruccions OpIMM
/// \param    inst: La instruccio
///
void RISCVSim::executeOpIMM(
    uint32_t inst) {

    traceInst(inst);

    unsigned rd = (inst >> 7) & 0x1F;
    unsigned rs1 = (inst >> 15) & 0x1F;
    uint32_t imm =
        ((inst >> 20) & 0x00000FFF) |
        ((inst & 0x80000000) ? 0xFFFFF000 : 0);
    uint32_t shamt = ((inst >> 20) & 0x1F);

    uint32_t v = 0;
    switch ((inst >> 12) & 0x07) {
        case 0b000: // ADDI
            v = r[rs1] + imm;
            break;

        case 0b110: // ORI
            v = r[rs1] | imm;
            break;

        case 0b111: // ANDI
            v = r[rs1] & imm;
            break;
    }

    r[rd] = v;
    pc += 4;

    traceReg(rd, r[rd]);
}


void RISCVSim::executeLoad(
    uint32_t inst) {

    traceInst(inst);
}


void RISCVSim::executeStore(
    uint32_t inst) {

    traceInst(inst);
}


void RISCVSim::executeBranch(
    uint32_t inst) {

    traceInst(inst);
}


uint32_t RISCVSim::expand(
    uint32_t inst) {

    return inst;
}


void RISCVSim::traceInst(uint32_t inst) {

    tracer->traceInst(pc, inst);
}


void RISCVSim::traceReg(uint32_t reg, uint32_t data) {

    tracer->traceReg(reg, data);
}

void RISCVSim::traceMem(uint32_t addr, uint32_t data) {

    tracer->traceMem(addr, data);
}