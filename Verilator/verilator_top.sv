`include "RV.svh"


`ifdef VERILATOR
`include "Types.sv"
`endif


module top
    import Types::*;
(
    input         i_clock,   // Clock
    input         i_reset);  // Reset

    DataMemoryBus dataBus;      // Interficie amb la memoria de dades
    InstMemoryBus instBus;      // Interficie amb la memoria d'instruccions


    // -------------------------------------------------------------------
    // Memoria d'instruccions
    // -------------------------------------------------------------------

    InstMemory #(
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


    // -------------------------------------------------------------------
    // Procesador
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
