module Multiplier (
    input  ProcessorDefs::Data i_operandA,
    input  ProcessorDefs::Data i_operandB,
    output ProcessorDefs::Data o_result);

    assign o_result = i_operandA * i_operandB;

endmodule
