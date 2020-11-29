module Alu 
#(
    parameter WIDTH = 32)           // Amplada de dades
(
    input  Types::AluOp i_Op,       // Operacio
    
    input  [WIDTH-1:0]  i_OperandA, // Operand A
    input  [WIDTH-1:0]  i_OperandB, // Operand B
    
    output [WIDTH-1:0]  o_Result);  // Resultat
    

    import Types::*;


    always_comb begin
        
        case (i_Op) 
            AluOp_ADD: 
                o_Result = i_OperandA + i_OperandB;
            
            AluOp_SUB: 
                o_Result = i_OperandA - i_OperandB;
            
            AluOp_AND: 
                o_Result = i_OperandA & i_OperandB;
            
            AluOp_OR: 
                o_Result = i_OperandA | i_OperandB;
            
            AluOp_XOR: 
                o_Result = i_OperandA ^ i_OperandB;
            
            AluOp_SLT: 
                o_Result = $signed(i_OperandA) < $signed(i_OperandB) ? {{WIDTH-1{1'b0}}, 1'b1} : 0;
            
            AluOp_SLTU: 
                o_Result = i_OperandA < i_OperandB ? {{WIDTH-1{1'b0}}, 1'b1} : 0;
            
            default: 
                o_Result = 0;
        endcase
    end
    
  endmodule
