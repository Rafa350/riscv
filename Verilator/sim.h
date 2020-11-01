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
        unsigned size;
        uint32_t *mem;
    public:
        ROM();
        ROM(const char *fileName);
        uint32_t read(uint32_t addr) const;
        unsigned getSize() const { return size; }
        void dump(uint32_t addr, unsigned size);
};


class RAM {
    private:
        unsigned size;
        uint32_t *mem;
    public:
        RAM();
        RAM(const char *fileName);
        uint32_t read(uint32_t addr) const;
        uint8_t read(uint32_t addr, unsigned byte) const;
        void write(uint32_t addr, uint32_t data);
        void write(uint32_t addr, uint8_t data, unsigned byte);
        unsigned getSize() const { return size; }
        void dump(uint32_t addr, unsigned size);
};


#endif
