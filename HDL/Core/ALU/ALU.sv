module ALU
    import Types::*;
(
    input  AluOp i_op,
    input  Data  i_dataA,
    input  Data  i_dataB,
    output Data  o_result);


    Data dataA;
    Data dataB;
    logic carry;

    logic comparator_isLessUnsigned;
    logic comparator_isLessSigned;


    // verilator lint_off PINMISSING
    Adder #(
        .WIDTH ($size(Data)))
    adder(
        .i_operandA (dataA),
        .i_operandB (dataB),
        .i_carry    (carry),
        .o_result   (o_result));
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

        dataA = i_dataA;
        dataB = Data'(0);
        carry = 1'b0;

        // verilator lint_off CASEINCOMPLETE
        unique case (i_op)

            AluOp_ADD:
                dataB  = i_dataB;

            AluOp_SUB: begin
                dataB = ~i_dataB;
                carry = 1'b1;
            end

            AluOp_AND:
                dataA = i_dataA & i_dataB;

            AluOp_OR:
                dataA = i_dataA | i_dataB;

            AluOp_XOR:
                dataA = i_dataA ^ i_dataB;

            AluOp_SLT:
                dataA = Data'(comparator_isLessSigned);

            AluOp_SLTU:
                dataA = Data'(comparator_isLessUnsigned);
        endcase
        // verilator lint_on CASEINCOMPLETE
    end

 endmodule
