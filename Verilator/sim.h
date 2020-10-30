#ifndef __SIM_H
#define __SIM_H


#include "verilated.h"
#include "Vtop.h"
#if VM_TRACE
#include <verilated_vcd_c.h>
#endif
#include <stdio.h>


extern void disassembly(unsigned addr, unsigned data);


class ROM {
    private:
        unsigned memSize;
        unsigned *mem;
    public:
        ROM();
        ROM(const char *fileName);
        unsigned read(unsigned addr) const;
        unsigned getSize() const { return memSize; }
};


class RAM {
    private:
        unsigned memSize;
        unsigned *mem;
    public:
        RAM();
        RAM(const char *fileName);
        unsigned read(unsigned addr) const;
        void write(unsigned addr, unsigned data);
        unsigned getSize() const { return memSize; }
};


#endif
