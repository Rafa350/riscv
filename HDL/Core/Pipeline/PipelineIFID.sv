`include "RV.svh"


module PipelineIFID
    import Types::*;
(
    // Senyals de control
    input  logic    i_clock,           // Clock
    input  logic    i_reset,           // Reset
    input  logic    i_stall,           // Retorna el mateix estat
    input  logic    i_flush,           // Retorna el estat NOP

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


    always_ff @(posedge i_clock)
        case ({i_reset, i_stall, i_flush})
            3'b100, // RESET
            3'b101, // RESET
            3'b110, // RESET
            3'b111, // RESET
            3'b001: // FLUSH
                begin
                    o_pc             <= InstAddr'(-4);
                    o_inst           <= Inst'(0);
                    o_instCompressed <= 1'b0;
                end

            3'b000: // NORMAL
                begin
                    o_pc             <= i_pc;
                    o_inst           <= i_inst;
                    o_instCompressed <= i_instCompressed;
                end

            3'b010, // STALL
            3'b011: // STALL
                begin
                    o_pc             <= o_pc;
                    o_inst           <= o_inst;
                    o_instCompressed <= o_instCompressed;
                end
        endcase


`ifdef DEBUG
    always_ff @(posedge i_clock)
        case ({i_reset, i_stall, i_flush})
            3'b100, // RESET
            3'b101, // RESET
            3'b110, // RESET
            3'b111, // RESET
            3'b001: // FLUSH
                begin
                    o_dbgOk   <= 1'b0;
                    o_dbgTick <= i_flush ? i_dbgTick : 0;
                end

            3'b000: // NORMAL
                begin
                    o_dbgOk   <= i_dbgOk;
                    o_dbgTick <= i_dbgTick;
                end

            3'b010, // STALL
            3'b011: // STALL
                begin
                    o_dbgOk   <= o_dbgOk;
                    o_dbgTick <= o_dbgTick;
                end
        endcase
`endif


endmodule
