module DebugPipelineEXMEM
    import Types::*;
(
    // Senyals de control
    input  logic i_clock,    // Clock
    input  logic i_reset,    // Reset
    input  logic i_stall,    // Retorna el mateix estat. Te prioritat sobre flush
    input  logic i_flush,    // Retorna l'estat NOP

    // Senyals d'entrada del pipeline
    input  int   i_dbgTick,  // Numero de tick
    input  Inst  i_dbgInst,  // Instruccio

    // Senyals de sortidade del pipeline
    output int   o_dbgTick,  // Numero de tick
    output Inst  o_dbgInst); // Instruccio


    always_ff @(posedge i_clock)
        casez ({i_reset, i_stall, i_flush})
            3'b1??, // RESET
            3'b001: // FLUSH
                begin
                    o_dbgTick <= i_flush ? i_dbgTick : 0;
                    o_dbgInst <= Inst'(0);
                end

            3'b01?: // STALL
                ;

            3'b000: // NORMAL
                begin
                    o_dbgTick <= i_dbgTick;
                    o_dbgInst <= i_dbgInst;
                end
        endcase


endmodule
