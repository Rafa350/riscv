// -----------------------------------------------------------------------
//       TEXT SECTION
// -----------------------------------------------------------------------

    .section .text
    .option norvc

_reset_handler:
_start:
    .global _start

    // Inicialitza mtvec
    //   MTVEC.BASE=0
    //   MTVEC.MODE=0
    csrrw zero, mtvec, zero

    // Inicialitza els contadors
    //   MCYCLE=0
    //   MINSTRET=0
    csrrsi zero, mcountinhibit, 0x5 // Primer els deshabilita
    csrrw zero, mcycle, zero        // Els posa a zero
    csrrw zero, minstret, zero
    csrrci zero, mcountinhibit, 0x5 // Els torna a habilitar

    // Inicialitza els registres a zero
    mv ra, zero
    mv tp, zero
    mv t0, zero
    mv t1, zero
    mv t2, zero
    mv s0, zero
    mv s1, zero
    mv a0, zero
    mv a1, zero
    mv a2, zero
    mv a3, zero
    mv a4, zero
    mv a5, zero
    mv a6, zero
    mv a7, zero
    mv s2, zero
    mv s3, zero
    mv s4, zero
    mv s5, zero
    mv s6, zero
    mv s7, zero
    mv s8, zero
    mv s9, zero
    mv s10, zero
    mv s11, zero
    mv t3, zero
    mv t4, zero
    mv t5, zero
    mv t6, zero

    // Inicialitza el stack pointer
    la sp, _stack_start

    // Inicialitza el global pointer
    mv gp, zero

    // Executa la funcio main
    addi a0, zero, 0
    addi a1, zero, 0
    jal ra, main

    // Recupera els contadors
    csrr t0, mcycle
    csrr t1, minstret
    lui t2, 0x100
    addi t2, t2, 0x20
    sw t0, 0(t2)
    sw t1, 4(t2)

    // Finalitzacio
_loop:
    j _loop


// ***********************************************************************
//       VECTORS SECTION
// ***********************************************************************

    .section .vectors, "ax"
    .option norvc

    .org 0x00
    jal zero, _reset_handler