module PipelineIFID
    import Types::*;
(
    // Senyals de control
    input  logic    i_clock,           // Clock
    input  logic    i_reset,           // Reset
    input  logic    i_stall,           // Retorna el mateix estat

    // Senyals d'entrada del pipeline
    input  logic    i_isValid,         // Indica operacio valida
    input  InstAddr i_pc,              // Contador d eprograma
    input  Inst     i_inst,            // Instruccio
    input  logic    i_instCompressed,  // Indica que es una instruccio comprimida

    // Senyals de sortida del pipeline
    output logic    o_isValid,         // Indica operacio valida
    output InstAddr o_pc,              // Contador de programa
    output Inst     o_inst,            // Instruccio
    output logic    o_instCompressed); // Indica que es una instruccio comprimida


    always_ff @(posedge i_clock)
        casez ({i_reset, i_stall})
            2'b1?: // RESET
                begin
                    o_isValid <= 1'b0;
                    o_pc      <= InstAddr'(-4);
                end

            2'b01: // STALL
                ;

            2'b00: // NORMAL
                begin
                    o_isValid        <= i_isValid;
                    o_pc             <= i_pc;
                    o_inst           <= i_inst;
                    o_instCompressed <= i_instCompressed;
                end
        endcase

endmodule
