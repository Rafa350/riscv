    .section .text

_reset_handler:
_start:
    .global _start
    
    // Operacions inmediates no relacionades
    addi    a0, zero, 0
    addi    a1, zero, 1
    addi    a2, zero, 2
    addi    a3, zero, 3
    addi    a4, zero, 4

    // Operacions no relacionades
    add     a0, a0, a1
    add     a0, a0, a2
    add     a0, a0, a3
    add     a0, a0, a4

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
