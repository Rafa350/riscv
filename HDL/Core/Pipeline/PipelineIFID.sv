`include "RV.svh"


module PipelineIFID
    import Types::*;
(
    // Senyals de control
    input  logic    i_clock,   // Clock
    input  logic    i_reset,   // Reset
    input  logic    i_stall,   // Dehabilita l'anvançament

`ifdef DEBUG
    // Senyals d'entrada de depuracio
    input  int      i_dbgTick, // Numero de tick
    input  logic    i_dbgOk,   // Indicador d'iInstruccio executada
    input  InstAddr i_dbgPc,   // Adressa de la instruccio
    input  Inst     i_dbgInst, // Instruccio

    // Senyals de sortidade depuracio
    output int      o_dbgTick, // Numero de tick
    output logic    o_dbgOk,   // Indicador d'instruccio executada
    output InstAddr o_dbgPc,   // Adressa de la instruccio
    output Inst     o_dbgInst, // Instruccio
`endif

    // Senyals d'entrada del pipeline
    input  InstAddr i_pc,      // Contador d eprograma
    input  Inst     i_inst,    // Instruccio

    // Senyals de sortida del pipeline
    output InstAddr o_pc,      // Contador de programa
    output Inst     o_inst);   // Instruccio


    always_ff @(posedge i_clock) begin
        o_pc      <= i_reset ? -4                  : (i_stall ? o_pc   : i_pc);
        o_inst    <= i_reset ? {$size(Inst){1'b0}} : (i_stall ? o_inst : i_inst);
`ifdef DEBUG
        o_dbgTick <= i_stall ? o_dbgTick : i_dbgTick;
        o_dbgOk   <= i_reset ? 1'b0 : (i_stall ? o_dbgOk : i_dbgOk);
        o_dbgPc   <= i_stall ? o_dbgPc   : i_dbgPc;
        o_dbgInst <= i_stall ? o_dbgInst : i_dbgInst;
`endif
    end


endmodule
