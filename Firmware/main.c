#include <stdint.h>


int main(
    int argc,
    char *argv[]) {

    char *p = (char*) 0x100020;

    for (int i = 0; i < 128; i++)
        *p++ = i;

    return 0;
}
