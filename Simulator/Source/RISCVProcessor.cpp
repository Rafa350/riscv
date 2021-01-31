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
    for (gpr_t i = 0; i < sizeof(r) / sizeof(r[0]); i++)
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
            executeSystem(inst);
            break;

        default:
            pc += 4;
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
    gpr_t rd = (inst >> 7) & 0x1F;
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
    gpr_t rd = (inst >> 7) & 0x1F;
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
    gpr_t rd = (inst >> 7) & 0x1F;
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
    gpr_t rd = (inst >> 7) & 0x1F;
    gpr_t rs1 = (inst >> 15) & 0x1F;
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
    gpr_t rd  = (inst >> 7) & 0x1F;
    gpr_t rs1 = (inst >> 15) & 0x1F;
    gpr_t rs2 = (inst >> 20) & 0x1F;

    // Execucio
    //
    data_t data = 0;
    switch ((inst >> 25) & 0b1111111) {
        case 0b0000000:
            switch ((inst >> 12) & 0b111) {
                case 0b000: // ADD
                    data = r[rs1] + r[rs2];
                    break;

                case 0b001: // SLL
                    data = r[rs1] << (r[rs2] & 0x001F);
                    break;

                case 0b010: // SLT
                    data = signed(r[rs1]) < signed(r[rs2]);
                    break;

                case 0b011: // SLTU
                    data = unsigned(r[rs1]) < unsigned(r[rs2]);
                    break;

                case 0b100: // XOR
                    data = r[rs1] ^ r[rs2];
                    break;

                case 0b101: // SRL
                    data = unsigned(r[rs1]) >> (r[rs2] & 0x001F);
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
                    data = signed(r[rs1]) >> (r[rs2] & 0x001F);
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
    gpr_t rd = (inst >> 7) & 0x1F;
    gpr_t rs1 = (inst >> 15) & 0x1F;
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
    gpr_t rd = (inst >> 7) & 0x1F;
    gpr_t rs1 = (inst >> 15) & 0x1F;
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
    gpr_t rs1 = (inst >> 15) & 0x1F;
    gpr_t rs2 = (inst >> 20) & 0x1F;
    data_t offset =
        (((inst & 0xFE000000) >> 25) << 5) |
        ((inst & 0x00000F80) >> 7) |
        ((inst & 0x80000000) ? 0xFFFFF000 : 0);

    // Execucio
    //
    addr_t addr = offset + r[rs1];
    data_t data = r[rs2];
    int access = (inst >> 12) & 0b111;
    switch (access) {
        case 0: // Byte
            dataMem->write8(addr, data);
            break;

        case 1: // Half
            dataMem->write16(addr, data);
            break;

        case 2: // Word
            dataMem->write32(addr, data);
            break;
    }

    pc += 4;

    // Traçat
    //
    traceMem(addr, access);
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
    gpr_t rs1 = (inst >> 15) & 0x1F;
    gpr_t rs2 = (inst >> 20) & 0x1F;
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
            br = signed(r[rs1]) >= signed(r[rs2]);
            break;

        case 0b110: // BLTU
            br = unsigned(r[rs1]) < unsigned(r[rs2]);
            break;

        case 0b111: // BGEU
            br = unsigned(r[rs1]) >= unsigned(r[rs2]);
            break;

    }

    pc += br ? offset : 4;
}


/// ----------------------------------------------------------------------
/// \brief    Exxecuta el grup d'instruccions System
/// \param    inst: La instruccio a executar
///
void Processor::executeSystem(
    inst_t inst) {

    // Traçat
    //
    traceInst(inst);

    // Decodificacio
    //
    gpr_t rd = (inst >> 7) & 0x1F;
    gpr_t rs1 = (inst >> 15) & 0x1F;
    unsigned cs = (inst >> 20) & 0xFFF;
    unsigned imm = (inst >> 15) & 0x1F;

    // Execucio
    //
    if (((inst >> 12) & 0b111) == 0) {
    }
    else {
        switch ((inst >> 12) & 0b111) {
            case 0b001: // CSRRW
                r[rd]   = csr[cs];
                csr[cs] = r[rs1];
                break;

            case 0b010: // CSRRS
                r[rd]   = csr[cs];
                csr[cs] = csr[cs] | r[rs1];
                break;

            case 0b011: // CSRRC
                r[rd]   = csr[cs];
                csr[cs] = csr[cs] & ~r[rs1];
                break;

            case 0b101: // CSRRWI
                r[rd] = (csr[cs] & 0x1F) | imm;
                break;

            case 0b110: // CSRRSI
                r[rd] = csr[cs] | imm;
                break;

            case 0b111: // CSRRCI
                r[rd] = csr[cs] & ~imm;
                break;
        }
    }

    pc += 4;

    // Traçat
    //
    if (((inst >> 12) & 0b111) != 0)
        traceReg(rd);
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
    gpr_t reg) {

    if (tracer)
        tracer->traceReg(reg, r[reg]);
}


void Processor::traceMem(
    addr_t addr,
    int access) {

    if (tracer) {
        switch (access) {
            case 0: // Byte
                tracer->traceMem(addr, dataMem->read8(addr), 0);
                break;

            case 1: // Half
                tracer->traceMem(addr, dataMem->read16(addr), 1);
                break;

            case 2: // Word
                tracer->traceMem(addr, dataMem->read32(addr), 2);
                break;
        }
    }
}


void Processor::traceTick() {

    if (tracer)
        tracer->traceTick(tick);
}
