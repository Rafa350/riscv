// verilator lint_off DECLFILENAME 


`ifdef VERILATOR
`include "types.sv"
`endif
 
 
`define DATA_WIDTH 32
`define ADDR_WIDTH 10
`define PC_WIDTH   10
`define REG_WIDTH  5
`define FIRMWARE   "firmware.txt"

`define PIPELINE


module top #(
    parameter DATA_WIDTH = `DATA_WIDTH,
    parameter ADDR_WIDTH = `ADDR_WIDTH,
    parameter PC_WIDTH   = `PC_WIDTH,
    parameter REG_WIDTH  = `REG_WIDTH,
    parameter FIRMWARE   = `FIRMWARE)
(
    input                   i_Clock,
    input                   i_Reset,

    input  logic [DATA_WIDTH-1:0] i_MemRdData,
    output logic [DATA_WIDTH-1:0] o_MemWrData,
    output logic [ADDR_WIDTH-1:0] o_MemAddr,
    output logic                  o_MemWrEnable,

    output logic [PC_WIDTH-1:0]   o_DbgPgmAddr,
    output logic [31:0]           o_DbgPgmInst);
    
    
    assign o_DbgPgmAddr = CPU_PgmAddr;
    assign o_DbgPgmInst = ROM_RdData;
    
    
    // -------------------------------------------------------------------
    // La memoria del programa
    // -------------------------------------------------------------------
    
    logic [31:0] ROM_RdData;
    
    RoMemory #(
        .DATA_WIDTH (32),
        .ADDR_WIDTH (PC_WIDTH),
        .FILE_NAME  (FIRMWARE))
    ROM (
        .i_Addr   (CPU_PgmAddr),
        .o_RdData (ROM_RdData));
    

    // -------------------------------------------------------------------
    // La memoria de dades
    // -------------------------------------------------------------------
    
    /*logic [DATA_WIDTH-1:0] RAM_RdData;
    
    RwMemory #(
        .DATA_WIDTH (DATA_WIDTH),
        .ADDR_WIDTH (ADDR_WIDTH))
    RAM (
        .i_Clock     (i_Clock),
        .i_Addr      (0),
        .i_WrEnable  (0),
        .i_WrData    (0),
        .o_RdData    (RAM_RdData));*/

    
    // -------------------------------------------------------------------
    // La CPU
    // -------------------------------------------------------------------
    
    logic [PC_WIDTH-1:0] CPU_PgmAddr;
    
`ifdef PIPELINE 
    ProcessorPP #(
`else
    ProcessorSC #(
`endif    
        .DATA_WIDTH (DATA_WIDTH), 
        .ADDR_WIDTH (ADDR_WIDTH),
        .PC_WIDTH   (PC_WIDTH),
        .REG_WIDTH  (REG_WIDTH)) 
    CPU (
        .i_Clock       (i_Clock),
        .i_Reset       (i_Reset),
        
        .o_PgmAddr     (CPU_PgmAddr),
        .i_PgmInst     (ROM_RdData),
        
        .o_MemAddr     (o_MemAddr),
        .o_MemWrEnable (o_MemWrEnable),
        .o_MemWrData   (o_MemWrData),
        .i_MemRdData   (i_MemRdData));
               
endmodule
