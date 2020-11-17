module PipelineEXMEM #(
    parameter DATA_WIDTH = 32,
    parameter REG_WIDTH  = 5)
(
    // Senyals de control
    input  logic                  i_Clock,        // Clock
    input  logic                  i_Reset,        // Reset

    input  logic [6:0]            i_InstOP,
    input  logic [DATA_WIDTH-1:0] i_Result,
    
    input  logic                  i_MemWrEnable,
    input  logic [DATA_WIDTH-1:0] i_MemWrData,
    input  logic [REG_WIDTH-1:0]  i_RegWrAddr,
    input  logic                  i_RegWrEnable,
    input  logic [1:0]            i_RegWrDataSel,

    output logic [6:0]            o_InstOP,
    output logic [DATA_WIDTH-1:0] o_Result,
    output logic                  o_MemWrEnable,
    output logic [DATA_WIDTH-1:0] o_MemWrData,
    output logic [REG_WIDTH-1:0]  o_RegWrAddr,
    output logic                  o_RegWrEnable,
    output logic [1:0]            o_RegWrDataSel);

    always_ff @(posedge i_Clock) begin
        o_InstOP       <= i_Reset ?  7'b0 : i_InstOP;
        o_Result       <= i_Reset ? 32'b0 : i_Result;
        o_MemWrEnable  <= i_Reset ?  1'b0 : i_MemWrEnable;
        o_MemWrData    <= i_Reset ? 32'b0 : i_MemWrData;
        o_RegWrAddr    <= i_Reset ?  5'b0 : i_RegWrAddr;
        o_RegWrEnable  <= i_Reset ?  1'b0 : i_RegWrEnable;
        o_RegWrDataSel <= i_Reset ?  2'b0 : i_RegWrDataSel;
    end


endmodule
