#ifndef __SIM_H
#define __SIM_H


#include "verilated.h"
#include "Vtop.h"
#if VM_TRACE
#include <verilated_fst_c.h>
#endif
#include <stdio.h>

#include "simTestbench.h"
#include "simMemory.h"


extern void disassembly(unsigned addr, uint32_t data);


class ROM: public Simulation::Memory {
    public:
        ROM();
};


class RAM: public Simulation::Memory {
    public:
        RAM();
};


#endif
