#pragma once


#include "RISCV.h"
#include <stdint.h>


namespace RISCV {

    class Memory {
        private:
            unsigned base;
            unsigned size;
            uint8_t *mem;
            bool allocated;

        public:
            Memory(uint8_t *memPtr, unsigned memBase, unsigned memSize);
            ~Memory();

            data_t read32(addr_t addr) const;
            data_t read16(addr_t addr) const;
            data_t read8(addr_t addr) const;

            void write32(addr_t addr, data_t data);
            void write16(addr_t addr, data_t data);
            void write8(addr_t addr, data_t data);

            inline uint8_t *getMem() const { return mem; }
            inline unsigned getSize() const { return size; }

            void dump(addr_t addr, unsigned length) const;

            void load(const char *fileName);
    };

}
