module ALU 
    import Types::*;
#(
    parameter WIDTH = 32)           // Amplada de dades
(
    input  Types::AluOp i_op,       // Operacio
    
    input  [WIDTH-1:0]  i_operandA, // Operand A
    input  [WIDTH-1:0]  i_operandB, // Operand B
    
    output [WIDTH-1:0]  o_result);  // Resultat
    

    always_comb begin       
        case (i_op) 
            AluOp_ADD: 
                o_result = i_operandA + i_operandB;
            
            AluOp_SUB: 
                o_result = i_operandA - i_operandB;
            
            AluOp_AND: 
                o_result = i_operandA & i_operandB;
            
            AluOp_OR: 
                o_result = i_operandA | i_operandB;
            
            AluOp_XOR: 
                o_result = i_operandA ^ i_operandB;
            
            AluOp_SLT: 
                o_result = $signed(i_operandA) < $signed(i_operandB) ? {{WIDTH-1{1'b0}}, 1'b1} : 0;
            
            AluOp_SLTU: 
                o_result = i_operandA < i_operandB ? {{WIDTH-1{1'b0}}, 1'b1} : 0;
            
            default: 
                o_result = 0;
        endcase
    end
    
  endmodule
