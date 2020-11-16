#ifndef __SIM_H
#define __SIM_H


#include "verilated.h"
#if VM_TRACE
#include <verilated_fst_c.h>
#endif
#include <stdio.h>

#include "Vverilator_top.h"


#include "simTestbench.h"
#include "simMemory.h"


typedef Vverilator_top Vtop;


class ROM: public Simulation::Memory {
    public:
        ROM();
};


class RAM: public Simulation::Memory {
    public:
        RAM();
};


extern void disassembly(unsigned addr, uint32_t data);


#endif
