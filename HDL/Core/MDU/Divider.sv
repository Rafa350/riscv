module Divider
    import Types::*;
(
    input  Data i_operandA,
    input  Data i_operandB,
    
    output Data o_result);    

    assign o_result = i_operandA / i_operandB;

endmodule
