`include "RV.svh"


module StageIF
    import Types::*;
(
    // Senyals de control
    input  logic         i_clock,  // Clock
    input  logic         i_reset,  // Reset

    // Senyals d'interficie am,b la memoria/cache d'instruccions
    InstMemoryBus.master instBus,  // Bus de la memoria d'instruccions

    // Senyals de control d'execucio
    input  InstAddr      i_pcNext,         // El nou PC
    output logic         o_hazard,         // Indica hazard
    output Inst          o_inst,           // Instruccio
    output logic         o_instCompressed, // Indica que la instruccio es comprimida
    output InstAddr      o_pc);            // PC


    // ------------------------------------------------------------------------
    // Obte la instruccio de la memoria, i si cal la expandeix.
    // ------------------------------------------------------------------------

`ifdef RV_EXT_C
    InstExpander
    exp (
        .i_inst         (instBus.inst),
        .o_inst         (o_inst),
        .o_isCompressed (o_instCompressed));
`else
      assign o_inst           = instBus.inst;
      assign o_instCompressed = 1'b0;
`endif


    // ------------------------------------------------------------------------
    // Control del PC
    // ------------------------------------------------------------------------

    assign o_pc           = i_pcNext;
    assign instBus.addr   = o_pc;

    assign o_hazard       = 1'b0;

endmodule
