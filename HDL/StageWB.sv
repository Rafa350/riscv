module StageWB 
#(
    parameter DATA_WIDTH = 32) 
(
    // verilator lint_off UNUSED
    input  logic                       i_Clock,
    input  logic                       i_Reset,
    // verilator lint_on UNUSED
    
    input  logic [DATA_WIDTH-1:0] i_RegWrData,
    
    output logic [DATA_WIDTH-1:0] o_RegWrData);

    assign o_RegWrData = i_RegWrData;

endmodule
