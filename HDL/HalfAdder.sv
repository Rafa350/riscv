module HalfAdder
#(
    parameter WIDTH = 32)
(
    input logic [WIDTH-1:0] i_OperandA,
    input logic [WIDTH-1:0] i_OperandB,
    
    output logic [WIDTH-1:0] o_Result);

    assign o_Result = i_OperandA + i_OperandB;
    
endmodule
