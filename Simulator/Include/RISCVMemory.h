#pragma once
#ifndef __RISCVMemory__
#define __RISCVMemory__


#include "RISCV.h"
#include <stdint.h>


namespace RISCV {

    class Memory {
        private:
            addr_t base;
            unsigned size;
            bool allocated;
            uint8_t *mem;

        public:
            Memory(uint8_t *memPtr, addr_t memBase, unsigned memSize);
            ~Memory();

            data_t read32(addr_t addr) const;
            data_t read16(addr_t addr) const;
            data_t read8(addr_t addr) const;

            void write32(addr_t addr, data_t data);
            void write16(addr_t addr, data_t data);
            void write8(addr_t addr, data_t data);

            inline uint8_t *getMem() const { return mem; }
            inline addr_t getBase() const { return base; }
            inline unsigned getSize() const { return size; }

            void dump(addr_t addr, unsigned length) const;

            void load(const char *fileName);
    };

}


extern "C" {
    int dpiMemCreate(int base, int size, long long *memObj);
    int dpiMemDestroy(const long long memObj);
    int dpiMemLoad(const long long memObj, const char* fileName);

    void dpiMemWrite8(const long long memObj, int addr, int data);
    void dpiMemWrite32(const long long memObj, int addr, int data);
    int dpiMemRead32(const long long memObj, int addr);
}


#endif // __RISCVMemory__
