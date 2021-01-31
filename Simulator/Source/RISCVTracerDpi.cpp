#include "RISCV.h"
#include "RISCVTracer.h"


using namespace RISCV;


/// ----------------------------------------------------------------------
/// \brief    Crea un objecte Tracer
/// \param    tracerObj: L'objecte creat.
/// \return   Zero si tot es correcte.
///
extern "C" int dpiTracerCreate(
    long long *tracerObj) {

    Tracer *tracer = new Tracer();
    if (tracer != nullptr) {
        *tracerObj = (long long) tracer;
        return 0;
    }
    else {
        *tracerObj = (long long) 0;
        return 1;
    }
}


/// ----------------------------------------------------------------------
/// \brief    Destrueix un objecte Tracer.
/// \param    tracerObj;: L'objecte a destruir.
/// \return   Zero si tot es correcte.
///
extern "C" int dpiTracerDestroy(
    const long long tracerObj) {

    Tracer *tracer = (Tracer*) tracerObj;

    if (tracer != nullptr) {
        delete tracer;
        return 0;
    }
    else
        return 1;

}


extern "C" void dpiTraceTick(
    const long long tracerObj,
    int tick) {

    Tracer *tracer = (Tracer*) tracerObj;
    tracer->traceTick(unsigned(tick));
}


extern "C" void dpiTraceInstruction(
    const long long tracerObj,
    int addr,
    int data) {

    Tracer *tracer = (Tracer*) tracerObj;
    tracer->traceInst(addr_t(addr), data_t(data));
}


extern "C" void dpiTraceRegister(
    const long long tracerObj,
    int addr,
    int data) {

    Tracer *tracer = (Tracer*) tracerObj;
    tracer->traceReg(gpr_t(addr), data_t(data));
}


extern "C" void dpiTraceMemory(
    const long long tracerObj,
    int addr,
    int access,
    int data) {

    Tracer *tracer = (Tracer*) tracerObj;
    tracer->traceMem(addr_t(addr), data_t(data), access);
}
