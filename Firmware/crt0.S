// -----------------------------------------------------------------------
//       TEXT SECTION
// -----------------------------------------------------------------------

    .section .text
    .option norvc

    // Entrada des del vector RESET
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
    //   MHPMCOUNTER3=0 // Contador d'accessos a lectura de memoria
    //   MHPMCOUNTER4=0 // Contador d'accessos a escriptura en memoria
    //
    csrrsi zero, mcountinhibit, 0x1D // Primer els deshabilita
    csrrw zero, mcycle, zero         // Els posa a zero
    csrrw zero, minstret, zero
    csrrw zero, mhpmcounter3, zero
    csrrw zero, mhpmcounter4, zero
    csrrw zero, mhpmevent3, 5        // Selecciona contador de lectures
    csrrw zero, mhpmevent4, 6        // Selecciona contador d'escriptures
    csrrci zero, mcountinhibit, 0x1D // Els torna a habilitar

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

    // Executa els test
    //jal ra, test

    // Inicialitza el stack pointer
    la sp, _stack_start

    // Inicialitza el global pointer
    mv gp, zero

    // Executa la funcio main
    addi a0, zero, 0
    addi a1, zero, 0
    jal ra, main

    // Recupera els contadors
    csrrsi zero, mcountinhibit, 0x1D // Primer els deshabilita, per no variar el resultat
    lui t0, 0x100
    addi t0, t0, 0x40
    csrr t1, mcycle
    sw t1, 0x0(t0)
    csrr t1, minstret
    sw t1, 0x4(t0)
    csrr t1, mhpmcounter3
    sw t1, 0x8(t0)
    csrr t1, mhpmcounter4
    sw t1, 0xC(t0)

    // Finalitzacio
_loop:
    j _loop


    // Entrada des del vector NMI
_nmi_handler:
    j _reset_handler


// ***********************************************************************
//       VECTORS SECTION
// ***********************************************************************

    .section .vectors, "ax"
    .option norvc

    .org 0x00
    jal zero, _reset_handler
    jal zero, _nmi_handler