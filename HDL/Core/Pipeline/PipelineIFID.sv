`include "RV.svh"


module PipelineIFID
    import Types::*;
(
    // Senyals de control
    input  logic    i_clock,           // Clock
    input  logic    i_reset,           // Reset
    input  logic    i_stall,           // Dehabilita l'anvançament

`ifdef DEBUG
    // Senyals d'entrada de depuracio
    input  int      i_dbgTick,         // Numero de tick
    input  logic    i_dbgOk,           // Indicador d'instruccio executada

    // Senyals de sortidade depuracio
    output int      o_dbgTick,         // Numero de tick
    output logic    o_dbgOk,           // Indicador d'instruccio executada
`endif

    // Senyals d'entrada del pipeline
    input  InstAddr i_pc,              // Contador d eprograma
    input  Inst     i_inst,            // Instruccio
    input  logic    i_instCompressed,  // Indica que es una instruccio comprimida

    // Senyals de sortida del pipeline
    output InstAddr o_pc,              // Contador de programa
    output Inst     o_inst,            // Instruccio
    output logic    o_instCompressed); // Indica que es una instruccio comprimida


    always_ff @(posedge i_clock) begin
        o_pc             <= i_reset ? InstAddr'(-4)       : (i_stall ? o_pc   : i_pc);
        o_inst           <= i_reset ? {$size(Inst){1'b0}} : (i_stall ? o_inst : i_inst);
        o_instCompressed <= i_reset ? 1'b0                : (i_stall ? o_instCompressed : i_instCompressed);
`ifdef DEBUG
        o_dbgTick        <= i_stall ? o_dbgTick           : i_dbgTick;
        o_dbgOk          <= i_reset ? 1'b0                : (i_stall ? o_dbgOk : i_dbgOk);
`endif
    end


endmodule
