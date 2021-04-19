module DebugPipelineIFID
    import ProcessorDefs::*;
(
    // Senyals de control
    input  logic i_clock,    // Clock
    input  logic i_reset,    // Reset
    input  logic i_stall,    // Retorna el mateix estat

    // Senyals d'entrada del pipeline
    input  int   i_dbgTick,  // Numero de tick

    // Senyals de sortidade del pipeline
    output int   o_dbgTick); // Numero de tick


    always_ff @(posedge i_clock)
        case ({i_reset, i_stall})
            2'b10, // RESET
            2'b11: // RESET
                o_dbgTick <= 0;

            2'b01: // STALL
                ;

            2'b00: // NORMAL
                o_dbgTick <= i_dbgTick;
        endcase

endmodule
