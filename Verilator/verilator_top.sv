`include "RV.svh"


`ifdef VERILATOR
`include "Config.sv"
`include "Types.sv"
`endif


module top
    import Config::*, Types::*;
(
    input         i_clock,   // Clock
    input         i_reset);  // Reset

    DataMemoryBus dataBus;      // Interficie amb la memoria de dades
    InstMemoryBus instBus;      // Interficie amb la memoria d'instruccions


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


    // -------------------------------------------------------------------
    // Procesador
    // -------------------------------------------------------------------

    generate
        if (RV_ARCH_CPU == "PP") begin
            ProcessorPP
            processor (
                .i_clock (i_clock),
                .i_reset (i_reset),
                .instBus (instBus),
                .dataBus (dataBus));
        end
        else if (RV_ARCH_CPU == "SC") begin
            ProcessorSC
            processor (
                .i_clock (i_clock),
                .i_reset (i_reset),
                .instBus (instBus),
                .dataBus (dataBus));
        end
    endgenerate


endmodule
