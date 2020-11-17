module PipelineMEMWB #(
    parameter DATA_WIDTH = 32,
    parameter REG_WIDTH  = 5)
(
    input  logic                  i_Clock,
    input  logic                  i_Reset,
    
    input  logic [REG_WIDTH-1:0]  i_RegWrAddr,
    input  logic                  i_RegWrEnable,
    input  logic [DATA_WIDTH-1:0] i_RegWrData,
    
    output logic [REG_WIDTH-1:0]  o_RegWrAddr,
    output logic                  o_RegWrEnable,
    output logic [DATA_WIDTH-1:0] o_RegWrData);

    always_ff @(posedge i_Clock) begin
        o_RegWrAddr    <= i_Reset ? 5'b0  : i_RegWrAddr;
        o_RegWrEnable  <= i_Reset ? 1'b0  : i_RegWrEnable;
        o_RegWrData    <= i_Reset ? 32'b0 : i_RegWrData;
    end

endmodule
