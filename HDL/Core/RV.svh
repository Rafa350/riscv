`ifndef __RV_SVH
`define __RV_SVH


// Procesador base
//
`define RV_BASE_RV32I        // Basic enters 32 bits
//`define RV_BASE_RV64I        // Basic enters 64 bits
//`define RV_BASE_RV128I       // Basic enters 128 bits


// Extensions del procesador
//
//`define RV_EXT_C             // Instruccions comprimides
//`define RV_EXT_M             // Multiplicacio i divisio d'enters


// Definicio de parametres fundamentals
//
`ifdef RV_BASE_RV32I
`define DATA_WIDTH 32
`define ADDR_WIDTH 32
`define PC_WIDTH   10
`define REG_WIDTH  5
`endif


// Definicio de parametres de depuracio
//
`define FIRMWARE   "firmware.txt"
`define PIPELINE
`define DEBUG


// Adresses dels vectors
//
`define RV_VECTOR_RESET  32'd0
`define RV_VECTOR_NMI    32'd4


`endif
