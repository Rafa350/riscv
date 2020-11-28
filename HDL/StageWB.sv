module StageWB
#(
    parameter DATA_WIDTH = 32,
    parameter REG_WIDTH  = 5)
(
    input  logic [DATA_WIDTH-1:0] i_RegWrData,
    input  logic [REG_WIDTH-1:0]  i_RegWrAddr,
    input  logic                  i_RegWrEnable);

    output logic [DATA_WIDTH-1:0] o_RegWrData,
    output logic [REG_WIDTH-1:0]  o_RegWrAddr,
    output logic                  o_RegWrEnable);


    assign o_RegWrData   = i_RegWrData;
    assign o_RegWrAddr   = i_RegWrAddr;
    assign o_RegWQEnable = i_RegWrEnable;

endmodule
