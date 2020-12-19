module PipelineMEMWB
    import Types::*;
(
    // Senyals de control
    input  logic    i_clock,       // Clock
    input  logic    i_reset,       // Reset
    input  logic    i_flush,       // Descarta les accions d'escriptura

    // Senyals de traçat
    input  TraceMEM i_trace,
    output TraceMEM o_trace,

    // Senyals d'entrada al pipeline
    input  RegAddr  i_regWrAddr,   // Registre per escriure
    input  logic    i_regWrEnable, // Autoritzacio per escriure
    input  Data     i_regWrData,   // Dades per escriure

    // Senyal de sortida del pipeline
    //
    output RegAddr  o_regWrAddr,
    output logic    o_regWrEnable,
    output Data     o_regWrData);


    always_ff @(posedge i_clock) begin
        o_regWrAddr   <= i_reset ? {$size(RegAddr){1'b0}} : i_regWrAddr;
        o_regWrEnable <= i_reset ? 1'b0                   : (i_flush ? 1'b0 : i_regWrEnable);
        o_regWrData   <= i_reset ? {$size(Data){1'b0}}    : i_regWrData;
    end

    always_ff @(posedge i_clock)
        o_trace <= i_trace;

endmodule
