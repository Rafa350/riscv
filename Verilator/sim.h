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

class Vverilator_top_ProcessorPP__Aa_Pa;

class RAM: public Simulation::Memory {
    public:
        RAM();
};


void printInstruction(unsigned addr, uint32_t data);
void printRegister(unsigned addr, uint32_t data);


#endif
