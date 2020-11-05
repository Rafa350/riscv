// verilator lint_off IMPORTSTAR 

 
import types::*;


module alu 
#(
    parameter WIDTH = 32)
(
    input  AluOp       i_op,       // Operacio
    
    input  [WIDTH-1:0] i_data_A,   // Operand A
    input  [WIDTH-1:0] i_data_B,   // Operand B
    input  logic       i_carry,    // Carry
    
    output [WIDTH-1:0] o_result,   // Resultat
    
    output logic       o_zero,     // Indicador Zero
    output logic       o_overflow, // Indicador Overflow
    output logic       o_carry);   // Carry
    
    always_comb
        case (i_op) 
            AluOp_ADD : o_result = i_data_A + i_data_B + {{WIDTH-1{1'b0}}, i_carry};
            AluOp_SUB : o_result = i_data_A - i_data_B;
            AluOp_AND : o_result = i_data_A & i_data_B;
            AluOp_OR  : o_result = i_data_A | i_data_B;
            AluOp_XOR : o_result = i_data_A ^ i_data_B;
            default: o_result = 0;
        endcase
        
    assign o_carry = 0;
    assign o_zero = !(|o_result);
    assign o_overflow = o_carry & o_result[WIDTH-1];
    
  endmodule
