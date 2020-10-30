// verilator lint_off IMPORTSTAR 

 
import types::*;


module alu 
#(
    parameter DATA_WIDTH = 32)
(
    input AluOp i_op,                            // Operation
    
    input [DATA_WIDTH-1:0] i_dataA,              // Operand A
    input [DATA_WIDTH-1:0] i_dataB,              // Operand B
    input logic i_carry,                         // Carry in
    
    output [DATA_WIDTH-1:0] o_result,            // Result
    
    output logic o_zero,                         // Zero flag
    output logic o_carry);                       // Carry out
    
    always_comb
        case (i_op) 
            AluOp_ADD : o_result = i_dataA + i_dataB + {{DATA_WIDTH-1{1'b0}}, i_carry};
            AluOp_SUB : o_result = i_dataA - i_dataB;
            AluOp_AND : o_result = i_dataA & i_dataB;
            AluOp_OR  : o_result = i_dataA | i_dataB;
            AluOp_XOR : o_result = i_dataA ^ i_dataB;
            default: o_result = 0;
        endcase
        
    assign o_carry = 0;
    assign o_zero = !(|o_result);
    
  endmodule
