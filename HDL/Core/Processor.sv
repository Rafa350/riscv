// TODO:
// El procesador ha de implementar la cache L2,
// Si no s'implementa L2 cal un mecanisme per unificas las dues memories
// La interficie de memoria es comun pedr dades i instruccions


module Processor
    import Config::*, Types::*;
(
    input  logic   i_clock,  // Clock
    input  logic   i_reset,  // Reset
    DataBus.master dataBus,  // Bus de la memoria de dades
    InstBus.master instBus); // Bus de la memoria d'instruccions


    InstBus coreInstBus(); // Bus d'instruccions
    DataBus coreDataBus(); // Bus de dades


    // -------------------------------------------------------------------
    // Cache L1 d'instruccions
    // -------------------------------------------------------------------

    generate
        if (RV_ICACHE_ON == 1) begin
            InstL1Cache
            instL1Cache (
                .i_clock (i_clock),      // Clock
                .i_reset (i_reset),      // Reset
                .bus     (instBus),      // Bus d'instruccions global
                .coreBus (coreInstBus)); // Bus d'instruccions local
        end
        else begin
            assign instBus.addr     = coreInstBus.addr;
            assign instBus.re       = coreInstBus.re;
            assign coreInstBus.inst = instBus.inst;
            assign coreInstBus.busy = instBus.busy;
        end
    endgenerate


    // ----------------------------------------------------------------------
    // Cache L1 de dades
    // ----------------------------------------------------------------------

    generate
        if (RV_DCACHE_ON == 1) begin
            /*DataL1Cache
            dataL1Cache (
                .i_clock (i_clock),      // Clock
                .i_reset (i_reset),      // Reset
                .bus     (dataBus),      // Bus de dades global
                .coreBus (coreDataBus)); // Bus de dades local*/
        end
        else begin
            assign dataBus.addr      = coreDataBus.addr;
            assign dataBus.we        = coreDataBus.we;
            assign dataBus.re        = coreDataBus.re;
            assign dataBus.be        = coreDataBus.be;
            assign dataBus.wdata     = coreDataBus.wdata;
            assign coreDataBus.rdata = dataBus.rdata;
            assign coreDataBus.busy  = dataBus.busy;
        end
    endgenerate


    // -------------------------------------------------------------------
    // Core
    // -------------------------------------------------------------------

    generate
        if (RV_ARCH_CPU == "PP") begin
            CorePP
            core (
                .i_clock (i_clock),
                .i_reset (i_reset),
                .instBus (coreInstBus),
                .dataBus (coreDataBus));
        end
        else if (RV_ARCH_CPU == "SC") begin
            CoreSC
            core (
                .i_clock (i_clock),
                .i_reset (i_reset),
                .instBus (coreInstBus),
                .dataBus (coreDataBus));
        end
    endgenerate


endmodule