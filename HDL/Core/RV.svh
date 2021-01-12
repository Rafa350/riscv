`ifndef __RV_SVH
`define __RV_SVH


// Procesador base
//
//`define RV_BASE_RV32E        // Basic enters 32 bits reduccio de registres
`define RV_BASE_RV32I        // Basic enters 32 bits
//`define RV_BASE_RV64I        // Basic enters 64 bits 
//`define RV_BASE_RV128I       // Basic enters 128 bits


// Extensions del procesador
//
//`define RV_EXT_B             // Manipulacio de bits
`define RV_EXT_C             // Instruccions comprimides
//`define RV_EXT_D             // Operacions float doble precissio (Implica RV_EXT_F)
//`define RV_EXT_F             // Operacions float simple precissio
//`define RV_EXT_M             // Multiplicacio i divisio d'enters


// Definicio de parametres fundamentals
//
`ifdef RV_BASE_RV32I
`define DATA_WIDTH 32
`ifdef RV_EXT_E
`define REG_WIDTH  4
`else
`define REG_WIDTH  5
`endif
`endif

`ifdef RV_BASE_RV64I
`define DATA_WIDTH 64
`define REG_WIDTH  5
`endif

`ifdef RV_BASE_RV128I
`define DATA_WIDTH 128
`define REG_WIDTH  5
`endif

`define ADDR_WIDTH 32
`define PC_WIDTH   12


// Definicio de parametres de depuracio
//
`define FIRMWARE   "firmware.txt"
`define PIPELINE
`define DEBUG


// Adresses dels vectors d'interrupcio
//
`define RV_VECTOR_RESET  32'h0
`define RV_VECTOR_NMI    32'h4


// Adresses dels blocs de memoria
//
`define RV_DMEM_BASE     32'h100000   // Adressa base de la memoria de dades
`define RV_DMEM_SIZE     32'd1024     // Tam,any de la memoria de dades en bytes


`endif
