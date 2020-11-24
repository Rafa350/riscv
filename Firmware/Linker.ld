STACK_SIZE = 1024;
RAM_SIZE   = 8192;
ROM_SIZE   = 2048;


MEMORY 
{
    ram     (rwx) : ORIGIN = 0x0000, LENGTH = RAM_SIZE
    rom      (rx) : ORIGIN = 0x8000, LENGTH = ROM_SIZE
}

SECTIONS 
{

    .text ORIGIN(rom) : 
    {
        *(.text*)
        *(.rodata*)
    } > rom
    
    .bss (NOLOAD) : 
    {
        *(.bss*)
        *(COMMON)
    } > ram
    
    .data ORIGIN(ram) : 
    {
        . = ALIGN(4);
        _sdata = .;
        *(.data*);
        . = ALIGN(4);
        _edata = .;
    } > ram 

    .stack (NOLOAD) : 
    {
        . = ALIGN(4);
        . = . + STACK_SIZE;
        . = ALIGN(4);
    } > ram
    
    _end = . ;
}
