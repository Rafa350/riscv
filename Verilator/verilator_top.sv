`include "RV.svh"


`ifdef VERILATOR
`include "Types.sv"
`endif


module top
    import Types::*;
#(

    parameter DATA_WIDTH = `DATA_WIDTH,
    parameter ADDR_WIDTH = `ADDR_WIDTH,
    parameter PC_WIDTH   = `PC_WIDTH,
    parameter REG_WIDTH  = `REG_WIDTH,
    parameter FIRMWARE   = `FIRMWARE)
(
    input           i_clock,
    input           i_reset,

    input  Data     i_memRdData,
    output Data     o_memWrData,
    output DataAddr o_memAddr,
    output logic    o_memWrEnable,

    output InstAddr o_dbgPgmAddr,
    output Inst     o_dbgPgmInst);


    DataMemoryBus dataBus;
    InstMemoryBus instBus;


    assign o_memAddr     = dataBus.master.addr;
    assign o_memWrData   = dataBus.master.wrData;
    assign o_memWrEnable = dataBus.master.wrEnable;


    assign o_dbgPgmAddr = instBus.slave.addr;
    assign o_dbgPgmInst = instBus.slave.inst;


    // -------------------------------------------------------------------
    // La memoria del programa
    // -------------------------------------------------------------------

    InstMemory #(
        .FILE_NAME (FIRMWARE))
    instMem (
        .bus (instBus));


    // -------------------------------------------------------------------
    // La memoria de dades
    // -------------------------------------------------------------------

    /*logic [DATA_WIDTH-1:0] RAM_RdData;

    RwMemory
    dataMem (
        .i_Clock     (i_Clock),
        .i_Addr      (0),
        .i_WrEnable  (0),
        .i_WrData    (0),
        .o_RdData    (RAM_RdData));*/


    // -------------------------------------------------------------------
    // La CPU
    // -------------------------------------------------------------------

    InstAddr CPU_PgmAddr;

`ifdef PIPELINE
    ProcessorPP #(
`else
    ProcessorSC #(
`endif
        .DATA_WIDTH (DATA_WIDTH),
        .ADDR_WIDTH (ADDR_WIDTH),
        .PC_WIDTH   (PC_WIDTH),
        .REG_WIDTH  (REG_WIDTH))
    processor (
        .i_clock (i_clock),
        .i_reset (i_reset),
        .instBus (instBus),
        .dataBus (dataBus));

endmodule
