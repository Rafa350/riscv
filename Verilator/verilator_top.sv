`include "RV.svh"


`ifdef VERILATOR
`include "Types.sv"
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


    DataMemoryBus #(
        .DATA_WIDTH (DATA_WIDTH),
        .ADDR_WIDTH (ADDR_WIDTH))
    DBus;

    InstMemoryBus #(
        .PC_WIDTH (PC_WIDTH))
    IBus;

    assign o_MemAddr     = DBus.Master.Addr;
    assign o_MemWrData   = DBus.Master.WrData;
    assign o_MemWrEnable = DBus.Master.WrEnable;


    assign o_DbgPgmAddr = IBus.Slave.Addr;
    assign o_DbgPgmInst = IBus.Slave.Inst;


    // -------------------------------------------------------------------
    // La memoria del programa
    // -------------------------------------------------------------------

    InstMemory #(
        .PC_WIDTH (PC_WIDTH),
        .FILE_NAME  (FIRMWARE))
    ROM (
        .IBus (IBus));


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
        .i_Clock   (i_Clock),
        .i_Reset   (i_Reset),
        .IBus      (IBus),
        .DBus      (DBus));

endmodule
