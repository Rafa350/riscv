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
    input             i_clock,
    input             i_reset,

    input  Data       i_memRdData,
    output Data       o_memWrData,
    output DataAddr   o_memAddr,
    output DataAccess o_memAccess,
    output logic      o_memWrEnable);


    DataMemoryBus dataBus;
    InstMemoryBus instBus;


    assign o_memAddr     = dataBus.master.addr;
    assign o_memAccess   = dataBus.master.access;
    assign o_memWrEnable = dataBus.master.wrEnable;
    assign o_memWrData   = dataBus.master.wrData;


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

    /*
    DataMemory
    dataMem (
        .i_Clock     (i_Clock),
        .i_bus       (dataBus));
    */


    // -------------------------------------------------------------------
    // La CPU
    // -------------------------------------------------------------------

`ifdef PIPELINE
    ProcessorPP
`else
    ProcessorSC
`endif
    processor (
        .i_clock (i_clock),
        .i_reset (i_reset),
        .instBus (instBus),
        .dataBus (dataBus));

endmodule
