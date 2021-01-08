module ALU 
    import Types::*;
(
    input  AluOp i_op,       // Operacio
    
    input  Data  i_operandA, // Operand A
    input  Data  i_operandB, // Operand B
    
    output Data  o_result);  // Resultat
    

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
                o_result = $signed(i_operandA) < $signed(i_operandB) ? {{$size(Data)-1{1'b0}}, 1'b1} : 0;
            
            AluOp_SLTU: 
                o_result = i_operandA < i_operandB ? {{$size(Data)-1{1'b0}}, 1'b1} : 0;
            
            default: 
                o_result = 0;
        endcase
    end
    
  endmodule
