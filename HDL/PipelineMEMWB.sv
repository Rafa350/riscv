module PipelineMEMWB
#(
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 32,
    parameter PC_WIDTH   = 32,
    parameter REG_WIDTH  = 5)
(
    // Senyals de control
    input  logic                  i_Clock,       // Clock
    input  logic                  i_Reset,       // Reset
    input  logic                  i_Flush,       // Descarta les accions d'escriptura

    // Senyals de depuracio
    input  logic [2:0]            i_DbgTag,
    output logic [2:0]            o_DbgTag,

    // Senyals d'entrada al pipeline
    input  logic [6:0]            i_InstOP,      // Instruccio
    input  logic [REG_WIDTH-1:0]  i_RegWrAddr,   // Registre per escriure
    input  logic                  i_RegWrEnable, // Autoritzacio per escriure
    input  logic [DATA_WIDTH-1:0] i_RegWrData,   // Dades per escriure

    // Senyal de sortida del pipeline
    //
    output logic [6:0]            o_InstOP,
    output logic [REG_WIDTH-1:0]  o_RegWrAddr,
    output logic                  o_RegWrEnable,
    output logic [DATA_WIDTH-1:0] o_RegWrData);


    always_ff @(posedge i_Clock) begin
        o_InstOP      <= i_Reset ? 7'b0               : i_InstOP;
        o_RegWrAddr   <= i_Reset ? {REG_WIDTH{1'b0}}  : i_RegWrAddr;
        o_RegWrEnable <= i_Reset ? 1'b0               : (i_Flush ? 1'b0 : i_RegWrEnable);
        o_RegWrData   <= i_Reset ? {DATA_WIDTH{1'b0}} : i_RegWrData;
        o_DbgTag      <= i_Reset ? 3'b0               : i_DbgTag;
    end

endmodule
