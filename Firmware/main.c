#include <stdint.h>


int main(
    int argc,
    char *argv[]) {

    char *p, *q;

    p = (char*) 0x100000;
    for (int i = 0; i < 16; i++)
        *p++ = 0xF0 + i;

    p = (char*) 0x100000;
    q = (char*) 0x100010;
    for (int i = 0; i < 16; i++)
        *q++ = *p++ & 0xEF;

    return 0;
}
