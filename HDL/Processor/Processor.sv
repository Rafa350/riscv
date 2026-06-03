module Processor (
                             // Senyals de control i sincronitzacio
    input  logic   i_clock,  //   Clock
    input  logic   i_reset,  //   Reset
                             // Interficies
    InstBus.master instBus,  //   Bus de la memoria d'instruccions
    DataBus.master dataBus); //   Bus de la memoria de dades


    InstBus coreInstBus(); // Bus d'instruccions del core
    DataBus coreDataBus(); // Bus de dades del core


    // -------------------------------------------------------------------
    // Cache L1 d'instruccions
    // Si esta habilitat el bus extern s'uneix al bus del core
    // pel cache, en cas contrari s'uneixen directament
    // -------------------------------------------------------------------

    generate
        if (Config::RV_ICACHE_ON == 1) begin
            InstL1Cache
            instL1Cache (
                .i_clock (i_clock),      // Clock
                .i_reset (i_reset),      // Reset
                .bus     (instBus),      // Bus d'instruccions extern
                .coreBus (coreInstBus)); // Bus d'instruccions del core
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
    // Si esta habilitat el bus extern s'uneix al bus del core
    // pel cache, en cas contrari s'uneixen directament
    // ----------------------------------------------------------------------

    generate
        if (Config::RV_DCACHE_ON == 1) begin
            DataL1Cache
            dataL1Cache (
                .i_clock (i_clock),      // Clock
                .i_reset (i_reset),      // Reset
                .bus     (dataBus),      // Bus de dades global
                .coreBus (coreDataBus)); // Bus de dades del core
        end
        else begin
            assign dataBus.addr      = coreDataBus.addr;
            assign dataBus.re        = coreDataBus.re;
            assign dataBus.we        = coreDataBus.we;
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
        if (Config::RV_ARCH_PIPELINE == 1) begin
            CorePP
            core (
                .i_clock (i_clock),
                .i_reset (i_reset),
                .instBus (coreInstBus),
                .dataBus (coreDataBus));
        end
        else begin
            CoreSC
            core (
                .i_clock (i_clock),
                .i_reset (i_reset),
                .instBus (coreInstBus),
                .dataBus (coreDataBus));
        end
    endgenerate


endmodule
