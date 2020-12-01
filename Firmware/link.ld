MEMORY
{
    rom      (rx) : ORIGIN = 0x00000000, LENGTH = 0x8000
    ram     (rwx) : ORIGIN = 0x00100000, LENGTH = 0x0100
    stack    (rw) : ORIGIN = 0x00100100, LENGTH = 0x0100
}

_min_stack   = 128;
_stack_len   = LENGTH(stack);
_stack_start = ORIGIN(stack) + LENGTH(stack);

_entry_point = ORIGIN(rom);

ENTRY(_start)

SECTIONS
{

    .text ORIGIN(rom) :
    {
        . = ALIGN(4);
        _stext = .;
        *(.text*)
        _etext = .;

        *(.rodata*)
    } > rom

    .rodata :
    {
        . = ALIGN(4);
        *(.rodata);
        *(.rodata.*)
    } > ram
    
    .srodata :
    {
        . = ALIGN(4);
        *(.srodata);
        *(.srodata.*)
    } > ram

    .shbss :
    {
        . = ALIGN(4),
        *(.shbss)
    } > ram

    .data :
    {
        . = ALIGN(4);
        sdata = .;
        _sdata = .;
        *(.data*);
        *(.data.*)
        . = ALIGN(4);
        edata = .;
        _edata = .;
    } > ram

    .bss (NOLOAD) :
    {
        . = ALIGN(4);
        _bss_start = .;
        *(.bss*)
        *(.bss.*)
        *(.sbss)
        *(.sbss.*)
        *(COMMON)
        _bss_end = .;
    } > ram

    .stack (NOLOAD) :
    {
        . = ALIGN(4);
        . = . + _min_stack;
        . = ALIGN(4);
        stack = .;
        _stack = .;
    } > stack

    _end = . ;
}
