    .section .text

_reset_handler:
_start:
    .global _start

    // Operacions inmediates no relacionades
    addi    a0, zero, 0x000
    addi    a1, zero, 0x111
    addi    a2, zero, 0x222

    // Operacions  relacionades
    add     a3, zero, a0
    add     a4, zero, a1
    add     a5, zero, a2

    lui     a0, 0x100
    addi    a0, a0, 0
    sw      a3, 0(a0)
    sw      a4, 4(a0)
    sw      a5, 8(a0)

_loop:
    j       _loop

/*
    j       _start

_unaligned_handler:
    .rep 10
    j       _default_handler
    .endr

_default_handler:
    j      _default_handler



_start:
    .global _start

    la      sp, _stack_start    // Inicialitza sp

    jal     ra, main            // crida a main()


    // Espera indefinidament
_loop:
    j       _loop
*/
