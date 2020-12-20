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
    input  InstAddr      i_pcNext, // El nou PC
    output Inst          o_inst,   // Instruccio
    output InstAddr      o_pc);    // PC


    // ------------------------------------------------------------------------
    // Control del PC
    // ------------------------------------------------------------------------

    assign o_pc         = i_pcNext;
    assign o_inst       = instBus.inst;
    assign instBus.addr = o_pc;

    // Mirar d'expandir la instruccio comprimida aqui

endmodule
