#include <stdint.h>


int main(
    int argc,
    char *argv[]) {

    char* p = (char*) 0x100000;

    for (int i = 0; i < 16; i++)
        *p++ = 0xF0 + i;

    return 0;
}
