module alu 
#(
    parameter DATA_WIDTH = 16)
(
    input [3:0] i_op,                            // Operation
    
    input [DATA_WIDTH-1:0] i_data1,              // Operand 1
    input [DATA_WIDTH-1:0] i_data2,              // Operand 2
    input logic i_carry,                         // Carry in
    
    output [DATA_WIDTH-1:0] o_result,            // Result
    
    output logic o_zero,                         // Zero flag
    output logic o_carry);                       // Carry out
    
    always_comb
        case (i_op) 
            4'd0   : o_result = i_data1 + i_data2 + i_carry;
            4'd1   : o_result = i_data1 & i_data2;
            4'd2   : o_result = i_data1 | i_data2;
            4'd3   : o_result = i_data1 ^ i_data2;
            default: o_result = 0;
        endcase
        
    assign o_zero = !(|o_result);
    
  endmodule
