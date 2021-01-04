MEMORY
{
    rom      (rx) : ORIGIN = 0x00000000, LENGTH = 0x8000
    ram     (rwx) : ORIGIN = 0x00100000, LENGTH = 0x0200
    stack    (rw) : ORIGIN = 0x00100200, LENGTH = 0x0100
}

_min_stack   = 128;
_stack_len   = LENGTH(stack);
_stack_start = ORIGIN(stack) + LENGTH(stack);

ENTRY(_reset_handler)

SECTIONS
{
    .text :
    {
        . = ALIGN(4);
        _stext = .;

        *(.text*)
        *(.text.*)

        . = ALIGN(4);
        _etext = .;
    } > rom

    .rodata :
    {
        . = ALIGN(4);

        *(.srodata);
        *(.srodata.*)
        *(.rodata);
        *(.rodata.*)
    } > rom

    .data :
    {
        . = ALIGN(4);
        sdata = .;
        _sdata = .;

        *(.sdata);
        *(.sdata.*)
        *(.data);
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

        . = ALIGN(4);
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

}
