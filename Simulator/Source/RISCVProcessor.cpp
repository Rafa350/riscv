#include "RISCV.h"
#include "RISCVProcessor.h"
#include "RISCVMemory.h"
#include "RISCVTracer.h"


using namespace RISCV;


/// ----------------------------------------------------------------------
/// \brief    Constructor
/// \param    tracer: El modul de traçat
/// \param    dataMem: Memoria de dades.
/// \param    instMem: Memeoria d'instruccions.
///
Processor::Processor(
    Tracer *tracer,
    Memory *dataMem,
    Memory *instMem) :

    tracer(tracer),
    dataMem(dataMem),
    instMem(instMem),
    tick(0),
    pc(0) {

    reset();
}


/// ----------------------------------------------------------------------
/// \brief    Reseteja el sistema
///
void Processor::reset() {

    // Inicialitza els registres
    //
    pc = 0;
    for (reg_t i = 0; i < sizeof(r) / sizeof(r[0]); i++)
        r[i] = 0;

    // Inicialitza el contador de tics
    //
    tick = 0;
}


/// ----------------------------------------------------------------------
/// @brief    Executa una instruccio.
/// @param    inst: La instruccio.
///
void Processor::execute(
    inst_t inst) {

    // Traçat
    //
    traceTick();

    // Expandeix la instruccio si cal
    //
    if ((inst & 0x3) != 0x3)
        inst = expand(inst);

    // Executa la instruccio
    //
    switch (OpCode(inst & 0b1111111)) {

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

        case OpCode::System:
            break;
    }

    // Incrementa el contador de tics
    //
    tick++;
}


/// ----------------------------------------------------------------------
/// @brief    Executa la instruccio AUIPC
/// @param    inst: La instruccio.
///
void Processor::executeAUIPC(
    inst_t inst) {

    // Traçat
    //
    traceInst(inst);

    // Decodificacio
    //
    reg_t rd = (inst >> 7) & 0x1F;
    data_t imm = inst & 0xFFFFF000;

    // Execucio
    //
    if (rd)
        r[rd] = pc + imm;
    pc += 4;

    // Traçat
    //
    traceReg(rd);
}


/// ----------------------------------------------------------------------
/// \brief    Executa la instruccio LUI
/// \param    inst: La instruccio.
///
void Processor::executeLUI(
    inst_t inst) {

    // Traçat
    //
    traceInst(inst);

    // Decodificacio
    //
    reg_t rd = (inst >> 7) & 0x1F;
    data_t imm = inst & 0xFFFFF000;

    // Execucio
    //
    if (rd)
        r[rd] = imm;
    pc += 4;

    // Traçat
    //
    traceReg(rd);
}


/// ----------------------------------------------------------------------
/// \brief    Executa la instruccio JAL
/// \param    inst: La instruccio.
///
void Processor::executeJAL(
    inst_t inst) {

    // Traçat
    //
    traceInst(inst);

    // Decodificacio
    //
    reg_t rd = (inst >> 7) & 0x1F;
    data_t imm =
        (((inst >> 21) & 0x000003FF) << 1) |
        (((inst >> 20) & 0x00000001) << 11) |
        (((inst >> 12) & 0x000000FF) << 12) |
        ((inst & 0x80000000) ? 0xFFF00000 : 0x00000000);

    // Execucio
    //
    if (rd)
        r[rd] = pc + 4;
    pc += imm;

    // Traçat
    //
    traceReg(rd);
}


/// ----------------------------------------------------------------------
/// \brief    Executa la instruccio JALR
///
void Processor::executeJALR(
    inst_t inst) {

    // Traçat
    //
    traceInst(inst);

    // Decodificacio
    //
    reg_t rd = (inst >> 7) & 0x1F;
    reg_t rs1 = (inst >> 15) & 0x1F;
    data_t imm =
        ((inst >> 20) & 1) |
        (inst & 0x80000000 ? 0xFFFFF000 : 0x00000000);

    // Execucio
    //
    if (rd)
        r[rd] = pc + 4;
    pc = r[rs1] + imm;

    // Traçat
    //
    traceReg(rd);
}


/// ----------------------------------------------------------------------
/// \brief    Executa el grup d'insatruccions Op
/// \param    inst: La instruccio.
///
void Processor::executeOp(
    inst_t inst) {

    // Traçat
    //
    traceInst(inst);

    // Decodificacio
    //
    reg_t rd  = (inst >> 7) & 0x1F;
    reg_t rs1 = (inst >> 15) & 0x1F;
    reg_t rs2 = (inst >> 20) & 0x1F;

    // Execucio
    //
    data_t data = 0;
    switch ((inst >> 25) & 0b1111111) {
        case 0b0000000:
            switch ((inst >> 12) & 0b111) {
                case 0b000: // ADD
                    data = r[rs1] + r[rs2];
                    break;

                case 0b001: //
                    break;

                case 0b010: //
                    break;

                case 0b011: //
                    break;

                case 0b100: // XOR
                    data = r[rs1] ^ r[rs2];
                    break;

                case 0b101: //
                    break;

                case 0b110: // OR
                    data = r[rs1] | r[rs2];
                    break;

                case 0b111: // AND
                    data = r[rs1] & r[rs2];
                    break;
            }
            break;

        case 0b0100000:
            switch ((inst >> 12) & 0b111) {
                case 0b000: // SUB
                    data = r[rs1] - r[rs2];
                    break;

                case 0b101: // SRA
                    break;
            }
            break;
    }

    if (rd)
        r[rd] = data;
    pc += 4;

    // Traçat
    //
    traceReg(rd);
}


/// ----------------------------------------------------------------------
/// \brief    Executa el grup d'instruccions OpIMM
/// \param    inst: La instruccio
///
void Processor::executeOpIMM(
    inst_t inst) {

    // Traçat
    //
    traceInst(inst);

    // Decodificacio
    //
    reg_t rd = (inst >> 7) & 0x1F;
    reg_t rs1 = (inst >> 15) & 0x1F;
    data_t imm =
        ((inst >> 20) & 0x00000FFF) |
        ((inst & 0x80000000) ? 0xFFFFF000 : 0);
    //data_t shamt = ((inst >> 20) & 0x1F);

    // Execucio
    //
    data_t data = 0;
    switch ((inst >> 12) & 0b111) {
        case 0b000: // ADDI
            data = r[rs1] + imm;
            break;

        case 0b110: // ORI
            data = r[rs1] | imm;
            break;

        case 0b111: // ANDI
            data = r[rs1] & imm;
            break;
    }

    if (rd)
        r[rd] = data;
    pc += 4;

    // Traçat
    //
    traceReg(rd);
}


/// ----------------------------------------------------------------------
/// \brief    Executa el grup d'instruccions Load
/// \param    inst: Instruccio.
///
void Processor::executeLoad(
    inst_t inst) {

    // Traçat
    //
    traceInst(inst);

    // Decodificacio
    //
    reg_t rd = (inst >> 7) & 0x1F;
    reg_t rs1 = (inst >> 15) & 0x1F;
    data_t offset =
        ((inst >> 20) & 0x00000FFF) |
        ((inst & 0x80000000) ? 0xFFFFF000 : 0);

    // Execucio
    //
    data_t data = 0;
    addr_t addr = offset + r[rs1];
    switch ((inst >> 12) & 0b111) {
        case 0b000: // LB
            data = dataMem->read8(addr);
            if (data & 0x80)
                data |= 0xFFFFFF00;
            break;

        case 0b001: // LH
            data = dataMem->read16(addr);
            if (data & 0x8000)
                data |= 0xFFFF0000;
            break;

        case 0b010: // LW
            data = dataMem->read32(addr);
            break;

        case 0b100: // LBU
            data = dataMem->read8(addr);
            break;

        case 0b101: // LHU
            data = dataMem->read16(addr);
            break;
    }

    if (rd)
        r[rd] = data;
    pc += 4;

    // Traçat
    //
    traceReg(rd);
}


/// ----------------------------------------------------------------------
/// \brief    Executa el grup d'instruccions Store
/// \param    inst: Instruccio.
///
void Processor::executeStore(
    inst_t inst) {

    // Traçat
    //
    traceInst(inst);

    // Decodificacio
    //
    reg_t rs1 = (inst >> 15) & 0x1F;
    reg_t rs2 = (inst >> 20) & 0x1F;
    data_t offset =
        (((inst & 0xFE000000) >> 25) << 5) |
        ((inst & 0x00000F80) >> 7) |
        ((inst & 0x80000000) ? 0xFFFFF000 : 0);

    // Execucio
    //
    addr_t addr = offset + r[rs1];
    data_t data = r[rs2];
    switch ((inst >> 12) & 0b111) {
        case 0b000: // SB
            dataMem->write8(addr, data);
            break;

        case 0b001: // SH
            dataMem->write16(addr, data);
            break;

        case 0b010: // SW
            dataMem->write32(addr, data);
            break;
    }

    pc += 4;

    // Traçat
    //
    traceMem(addr);
}


/// ----------------------------------------------------------------------
/// \brief    Executa el grup d'instruccions Branch
/// \param    inst: La instruccio.
///
void Processor::executeBranch(
    inst_t inst) {

    // Traçat
    //
    traceInst(inst);

    // Decodificacio
    //
    reg_t rs1 = (inst >> 15) & 0x1F;
    reg_t rs2 = (inst >> 20) & 0x1F;
    data_t offset =
        (((inst >> 7) & 0x00000001) << 11) |
        (((inst >> 8) & 0x0000000F) << 1) |
        (((inst >> 25) & 0x0000003F) << 5) |
        ((inst & 0x80000000) ? 0xFFFFF000 : 0);

    // Execucio
    //
    bool br = false;
    switch ((inst >> 12) & 0b111) {
        case 0b000: // BEQ
            br = r[rs1] == r[rs2];
            break;

        case 0b001: // BNE
            br = r[rs1] != r[rs2];
            break;

        case 0b100: // BLT
            br = signed(r[rs1]) < signed(r[rs2]);
            break;

        case 0b101: // BGE
            br = signed(r[rs1]) > signed(r[rs2]);
            break;

        case 0b110: // BLTU
            br = unsigned(r[rs1]) < unsigned(r[rs2]);
            break;

        case 0b111: // BGEU
            br = unsigned(r[rs1]) == unsigned(r[rs2]);
            break;

    }

    pc += br ? offset : 4;
}


/// ----------------------------------------------------------------------
/// \brief    Expandeix una instruccio comprimida
/// \param    inst: La instruccio comprimida
/// \return   La instruccio expandida.
///
uint32_t Processor::expand(
    inst_t inst) {

    return inst;
}


void Processor::traceInst(
    inst_t inst) {

    if (tracer)
        tracer->traceInst(pc, inst);
}


void Processor::traceReg(
    reg_t reg) {

    if (tracer)
        tracer->traceReg(reg, r[reg]);
}


void Processor::traceMem(
    addr_t addr) {

    if (tracer)
        tracer->traceMem(addr, dataMem->read32(addr));
}


void Processor::traceTick() {

    if (tracer)
        tracer->traceTick(tick);
}
