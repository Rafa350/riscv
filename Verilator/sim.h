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

class CPUAccess {
    private:
        Vtop *top;
        Vverilator_top_ProcessorPP__Aa_Pa *cpu;
        
    public:
        CPUAccess(Vtop* top);
        
        uint32_t getIFID_PC() const;
        uint32_t getIFID_Inst() const;
        
        uint32_t getIDEX_OP() const;
        uint32_t getIDEX_RS1() const;
        uint32_t getIDEX_RS2() const;
        uint32_t getIDEX_IMM() const;
        uint32_t getIDEX_DataA() const;
        uint32_t getIDEX_DataB() const;
        uint32_t getIDEX_RegWrAddr() const;    
        uint32_t getIDEX_RegWrEnable() const;    
        uint32_t getIDEX_RegWrDataSel() const;    

        uint32_t getEXMEM_RegWrAddr() const;    
        uint32_t getEXMEM_RegWrEnable() const;    
        uint32_t getEXMEM_RegWrDataSel() const;    
};


class RAM: public Simulation::Memory {
    public:
        RAM();
};


void printInstruction(unsigned addr, uint32_t data);
void printRegister(unsigned addr, uint32_t data);


#endif
