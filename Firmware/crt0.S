.section .text


    // Entrada del vector reset
reset_handler:
    la      sp, _stack_start    // Inicialitza sp


    // Entrada a l'aplicacio
_start:
    .global _start
    jal     ra, main            // crida a main()


    // Espera indefinidament
_loop:
    j       _loop
