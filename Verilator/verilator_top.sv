`include "RV.svh"


`ifdef VERILATOR
`include "Config.sv"
`include "ProcessorDefs.sv"
`include "CoreDefs.sv"
`include "CacheDefs.sv"
`endif


module top
    import Config::*, CoreDefs::*;
(
    input   i_clock,   // Clock
    input   i_reset);  // Reset

    DataBus dataBus; // Interficie amb la memoria de dades
    InstBus instBus; // Interficie amb la memoria d'instruccions


    // -------------------------------------------------------------------
    // Memoria d'instruccions
    // -------------------------------------------------------------------

    InstMemory #(
        .BASE (`RV_IMEM_BASE),
        .SIZE (`RV_IMEM_SIZE),
        .FILE_NAME (`FIRMWARE))
    instMem (
        .bus (instBus));


    // -------------------------------------------------------------------
    // La memoria de dades (Emulacio DPI)
    // -------------------------------------------------------------------

    DataMemory #(
        .BASE (`RV_DMEM_BASE),
        .SIZE (`RV_DMEM_SIZE))
    dataMem (
        .i_clock (i_clock),
        .bus     (dataBus));


    // verilator lint_off PINMISSING
    /*MemoryArbiter
    memoryArbiter (
        .i_clock (i_clock),
        .i_reset (i_reset),
        .instBus (instBus),
        .dataBus (dataBus));*/
    // verilator lint_on PINMISSING


    // -------------------------------------------------------------------
    // Procesador
    // -------------------------------------------------------------------

    Processor
    processor (
        .i_clock (i_clock),
        .i_reset (i_reset),
        .instBus (instBus),
        .dataBus (dataBus));


endmodule
