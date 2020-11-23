module PipelineMEMWB
#(
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 32,
    parameter PC_WIDTH   = 32,
    parameter REG_WIDTH  = 5)
(
    // Senyals de control
    input  logic                  i_Clock,
    input  logic                  i_Reset,

    // Senyals de depuracio
    input  logic [2:0]            i_DbgTag,
    output logic [2:0]            o_DbgTag,

    // Senyals de control del pipeline
    input  logic                i_Flush,
    input  logic                i_Stall,

    // Senyals d'entrada al pipeline
    input  logic [6:0]            i_InstOP,
    input  logic [REG_WIDTH-1:0]  i_RegWrAddr,
    input  logic                  i_RegWrEnable,
    input  logic [DATA_WIDTH-1:0] i_RegWrData,

    // Senyal de sortida del pipeline
    //
    output logic [6:0]            o_InstOP,
    output logic [REG_WIDTH-1:0]  o_RegWrAddr,
    output logic                  o_RegWrEnable,
    output logic [DATA_WIDTH-1:0] o_RegWrData);


    always_ff @(posedge i_Clock) begin
        o_InstOP      <= i_Reset ? 7'b0               : (i_Stall ? o_InstOP      : i_InstOP);
        o_RegWrAddr   <= i_Reset ? {REG_WIDTH{1'b0}}  : (i_Stall ? o_RegWrAddr   : i_RegWrAddr);
        o_RegWrEnable <= i_Reset ? 1'b0               : (i_Stall ? o_RegWrEnable : i_RegWrEnable);
        o_RegWrData   <= i_Reset ? {DATA_WIDTH{1'b0}} : (i_Stall ? o_RegWrData   : i_RegWrData);
        o_DbgTag      <= i_Reset ? 3'b0               : i_DbgTag;
    end

endmodule
