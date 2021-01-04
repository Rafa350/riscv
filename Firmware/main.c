#include <stdint.h>


int main(
    int argc,
    char *argv[]) {

    char* p = (char*) 0x100000;

    *p++ = 0xF0;
    *p++ = 0xF1;
    *p++ = 0xF2;
    *p++ = 0xF3;

    return 0;
}
