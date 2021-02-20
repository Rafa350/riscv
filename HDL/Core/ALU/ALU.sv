module ALU
    import Types::*;
(
    input  AluOp i_op,
    input  Data  i_dataA,
    input  Data  i_dataB,
    output Data  o_result);


    Data alu_result;
    logic comparator_isLessUnsigned;
    logic comparator_isLessSigned;


    // verilator lint_off PINMISSING
    Adder #(
        .WIDTH ($size(Data)))
    adder(
        .i_operandA (i_dataA),
        .i_operandB (i_op == AluOp_SUB ? ~i_dataB : i_dataB),
        .i_carry    (i_op == AluOp_SUB ? 1'b1 : 1'b0),
        .o_result   (alu_result));
    // verilator lint_on PINMISSING


    // verilator lint_off PINMISSING
    FullComparator #(
        .WIDTH ($size(Data)))
    comparator (
        .i_inputA         (i_dataA),
        .i_inputB         (i_dataB),
        .o_isLessUnsigned (comparator_isLessUnsigned),
        .o_isLessSigned   (comparator_isLessSigned));
    // verilator lint_on PINMISSING


    always_comb begin

        // verilator lint_off CASEINCOMPLETE
        unique case (i_op)

            AluOp_ADD,
            AluOp_SUB:
                o_result = alu_result;

            AluOp_AND:
                o_result = i_dataA & i_dataB;

            AluOp_OR:
                o_result = i_dataA | i_dataB;

            AluOp_XOR:
                o_result = i_dataA ^ i_dataB;

            AluOp_SLT:
                o_result = Data'(comparator_isLessSigned);

            AluOp_SLTU:
                o_result = Data'(comparator_isLessUnsigned);
        endcase
        // verilator lint_on CASEINCOMPLETE
    end

 endmodule
