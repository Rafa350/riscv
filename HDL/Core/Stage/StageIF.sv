`include "RV.svh"


module StageIF
    import Types::*;
(
    // Senyals de control i sincronitzacio
    input  logic         i_clock,  // Clock
    input  logic         i_reset,  // Reset

    // Interficie amb la memoria/cache d'instruccions
    InstMemoryBus.master instBus,  // Bus de la memoria d'instruccions

    // Senyals del stage MEM per la gestio dels hazards
    input  logic         i_MEM_isValid,     // Indica operacio valida en MEM
    input  logic         i_MEM_memRdEnable, // Indica operacio de lectura en MEM
    input  logic         i_MEM_memWrEnable, // Indica operacio d'escriptura en MEM

    // Senyals de control d'execucio
    input  InstAddr      i_pcNext,          // El nou PC
    output logic         o_hazard,          // Indica hazard
    output Inst          o_inst,            // Instruccio
    output logic         o_instCompressed,  // Indica que la instruccio es comprimida
    output InstAddr      o_pc);             // PC


    // ------------------------------------------------------------------------
    // Detecta els hazards deguts a accessos a memoria
    // ------------------------------------------------------------------------

    StageIF_HazardDetector
    hazardDetector(
        .i_MEM_isValid     (i_MEM_isValid),
        .i_MEM_memRdEnable (i_MEM_memRdEnable),
        .i_MEM_memWrEnable (i_MEM_memWrEnable),
        .o_hazard          (o_hazard)); // Indica que s'ha detectat un hazard


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

    assign o_pc         = i_pcNext;
    assign instBus.addr = o_pc;
    assign instBus.rd   = 1'b1;

endmodule
