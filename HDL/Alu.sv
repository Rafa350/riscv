// verilator lint_off IMPORTSTAR 

 
import types::*;


module Alu 
#(
    parameter WIDTH    = 32)       // Amplada de dades
(
    input  AluOp       i_Op,       // Operacio
    
    input  [WIDTH-1:0] i_OperandA, // Operand A
    input  [WIDTH-1:0] i_OperandB, // Operand B
    input  logic       i_Carry,    // Carry
    
    output [WIDTH-1:0] o_Result,   // Resultat
    
    output logic       o_Zero,     // Indicador Zero
    output logic       o_Overflow, // Indicador Overflow
    output logic       o_Carry);   // Carry
    
    always_comb begin
        
        case (i_Op) 
            AluOp_ADD : o_Result = i_OperandA + i_OperandB + {{WIDTH-1{1'b0}}, i_Carry};
            AluOp_SUB : o_Result = i_OperandA - i_OperandB;
            AluOp_AND : o_Result = i_OperandA & i_OperandB;
            AluOp_OR  : o_Result = i_OperandA | i_OperandB;
            AluOp_XOR : o_Result = i_OperandA ^ i_OperandB;
            default   : o_Result = 0;
        endcase
        
        o_Carry    = 0;
        o_Zero     = ~|o_Result;
        o_Overflow = o_Carry & o_Result[WIDTH-1];
    end
    
  endmodule
