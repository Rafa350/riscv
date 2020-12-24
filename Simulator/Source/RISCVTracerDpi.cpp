#include "RISCV.h"
#include "RISCVTracer.h"


using namespace RISCV;


static Tracer *tracer = nullptr;


static Tracer *getTracer() {

    if (!tracer)
        tracer = new Tracer();
    return tracer;
}


extern "C" void dpiTraceTick(
    int tick) {

    Tracer *tracer = getTracer();
    tracer->traceTick(unsigned(tick));
}


extern "C" void dpiTraceInstruction(
    int addr,
    int data) {

    Tracer *tracer = getTracer();
    tracer->traceInst(addr_t(addr), data_t(data));
}


extern "C" void dpiTraceRegister(
    int addr,
    int data) {

    Tracer *tracer = getTracer();
    tracer->traceReg(reg_t(addr), data_t(data));
}


extern "C" void dpiTraceMemory(
    int addr,
    int data) {

    Tracer *tracer = getTracer();
    tracer->traceMem(addr_t(addr), data_t(data));
}
