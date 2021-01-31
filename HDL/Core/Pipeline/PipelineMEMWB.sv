module PipelineMEMWB
    import Types::*;
(
    // Senyals de control
    input  logic      i_clock,          // Clock
    input  logic      i_reset,          // Reset
    input  logic      i_flush,          // Retorna l'estat NOP

    // Senyals d'entrada al pipeline
    input  logic       i_isValid,      // Indica operacio valida
    input  GPRAddr     i_regWrAddr,    // Registre per escriure
    input  logic       i_regWrEnable,  // Autoritzacio per escriure
    input  Data        i_regWrData,    // Dades per escriure

    // Senyal de sortida del pipeline
    //
    output logic       o_isValid,      // Indica operacio valida
    output GPRAddr     o_regWrAddr,
    output logic       o_regWrEnable,
    output Data        o_regWrData);


    always_ff @(posedge i_clock)
        casez ({i_reset, i_flush})
            2'b1?, // RESET
            2'b01: // FLUSH
                o_isValid <= 0;

            2'b00: // NORMAL
                begin
                    o_isValid     <= i_isValid;
                    o_regWrAddr   <= i_regWrAddr;
                    o_regWrEnable <= i_regWrEnable;
                    o_regWrData   <= i_regWrData;
                end
        endcase

endmodule
