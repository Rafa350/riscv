    .section .text

_reset_handler:
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
   