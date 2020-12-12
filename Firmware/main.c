#include <stdint.h>

void main(void) { 

    for (int i = 0; i < 4; i++)
        *((uint32_t*)0x200) = i;
}
