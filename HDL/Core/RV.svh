`ifndef __RV_SVH
`define __RV_SVH


// -----------------------------------------------------------------------
// Opcions de configuracio
// -----------------------------------------------------------------------

// Opcions de procesador base
//
//`define RV_BASE_RV32E        // Basic enters 32 bits reduccio de registres
`define RV_BASE_RV32I        // Basic enters 32 bits
//`define RV_BASE_RV64I        // Basic enters 64 bits


// Opcions de cache de dades
//
//`define RV_DCACHE_ON          // Cache L1 de dades


// Opcions d'elaboracio
//
`ifdef VERILATOR
`define RV_COMPILER_VERILATOR   // Elaboracio per Verilator
`endif
`ifdef QUARTUS
`define RV_COMPILER_QUARTUS     // Elaboracio per quartus
`endif

// -----------------------------------------------------------------------


// Definicio de parametres de depuracio
//
`define FIRMWARE   "firmware.txt"


// Adresses dels blocs de memoria
//
`define RV_IMEM_BASE     32'h000000   // Adressa base de la memoria d'instruccions
`define RV_IMEM_SIZE     32'd1024     // Tamany de la memoria d'instruccions en bytes
`define RV_DMEM_BASE     32'h100000   // Adressa base de la memoria de dades
`define RV_DMEM_SIZE     32'd1024     // Tamany de la memoria de dades en bytes


`endif
