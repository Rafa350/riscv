#ifndef __SIM_H
#define __SIM_H


#include "verilated.h"
#include "Vtop.h"
#if VM_TRACE
#include <verilated_vcd_c.h>
#endif
#include <stdio.h>


//#define BIG_ENDIAN     


extern void disassembly(unsigned addr, unsigned data);


class ROM {
    private:
        unsigned size;
        uint32_t *mem;
    public:
        ROM();
        ROM(const char *fileName);
        uint32_t read32(uint32_t addr) const;
        unsigned getSize() const { return size; }
        void dump(uint32_t addr, unsigned size);
};


class RAM {
    private:
        unsigned size;
        uint8_t *mem;
    public:
        RAM();
        RAM(const char *fileName);
        uint32_t read32(uint32_t addr) const;
        uint8_t read8(uint32_t addr) const;
        void write32(uint32_t addr, uint32_t data);
        void write8(uint32_t addr, uint8_t data);
        unsigned getSize() const { return size; }
        void dump(uint32_t addr, unsigned size) const;
};


#endif
