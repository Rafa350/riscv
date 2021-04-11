#include "RISCV.h"
#include "RISCVTracer.h"

#include <stdio.h>


using namespace RISCV;


/// ----------------------------------------------------------------------
/// \brief    Constructor del objecter
/// \param    tick: Numero de tick
/// \param    pc: Contador de programa
/// \param    inst: Instruccio
///
TracerInfo::TracerInfo(
    int tick,
    addr_t pc,
    inst_t inst):

    tick(tick),
    pc(pc),
    inst(inst),
    traceRegEnabled(false),
    traceMemEnabled(false) {

}


/// ----------------------------------------------------------------------
/// \brief    Accepta els paremtrers de traçat de registre
/// \param    reg: Nombre del registre
/// \param    value: Valor asignat
///
void TracerInfo::traceReg(
    gpr_t reg,
    data_t value) {

    traceRegEnabled = true;
    this->reg = reg;
    regValue = value;
}


/// ----------------------------------------------------------------------
/// \brief    Accepta els parametres de traçat de memoria.
/// \param    mem: Adressa de memoria
/// \param    value: Valor asignat
///
void TracerInfo::traceMem(
    addr_t mem,
    data_t value,
    int access) {

    traceMemEnabled = true;
    this->mem = mem;
    memValue = value;
    memAccess = access;
}


/// ----------------------------------------------------------------------
/// \brief    Presenta la informacio de traçat.
/// \param    tracer: Objecte que realitza la presentacio
///
void TracerInfo::trace(
    const Tracer *tracer) const {

    printf("%10.10d", tick);

    printf("      ");
    if (traceRegEnabled)
        tracer->traceReg(reg, regValue);
    else
        printf("-------------");


    printf("      ");
    if (traceMemEnabled)
        tracer->traceMem(mem, memValue, memAccess);
    else
        printf("------------------");

    printf("      ");
    tracer->traceInst(pc, inst);
}
