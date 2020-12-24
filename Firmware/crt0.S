    .section .text

_reset_handler:
_start:
    .global _start

    // Operacions inmediates no relacionades
    lui     a0, 0x100
    addi    a0, a0, 0x000

    addi    a1, zero, 0x111
    addi    a2, zero, 0x222
    addi    a3, zero, 0x333
    addi    a4, zero, 0x444

    sw      a4, 0(a0)
    sw      a3, 4(a0)
    sw      a2, 8(a0)
    sw      a1, 12(a0)

    lui     a0, 0x200
    addi    a1, zero, '*'
_loop:
    sw      a1, 0(a0)
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
