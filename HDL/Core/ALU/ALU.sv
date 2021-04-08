module ALU
    import Types::*;
(
    input  AluOp i_op,
    input  Data  i_dataA,
    input  Data  i_dataB,
    output Data  o_result);


    Data adder_result;
    Data shifter_result;
    logic comparator_isLessUnsigned;
    logic comparator_isLessSigned;


    // verilator lint_off PINMISSING
    Adder #(
        .WIDTH ($size(Data)))
    adder(
        .i_operandA (i_dataA),
        .i_operandB (i_dataB ^ {$size(Data){i_op == AluOp_SUB}}),
        .i_carry    (i_op == AluOp_SUB),
        .o_result   (adder_result));
    // verilator lint_on PINMISSING


    // verilator lint_off PINMISSING
    FullComparer #(
        .WIDTH ($size(Data)))
    comparator (
        .i_dataA          (i_dataA),
        .i_dataB          (i_dataB),
        .o_isLessUnsigned (comparator_isLessUnsigned),
        .o_isLessSigned   (comparator_isLessSigned));
    // verilator lint_on PINMISSING


    Shifter #(
        .WIDTH ($size(Data)))
    shifter (
        .i_data       (i_dataA),
        .i_bits       (i_dataB[4:0]),
        .i_left       (i_op == AluOp_SLL),
        .i_rotate     (0),
        .i_arithmetic (i_op == AluOp_SRA),
        .o_data       (shifter_result));


    always_comb begin

        // verilator lint_off CASEINCOMPLETE
        unique case (i_op)

            AluOp_ADD,
            AluOp_SUB:
                o_result = adder_result;

            AluOp_AND:
                o_result = i_dataA & i_dataB;

            AluOp_OR:
                o_result = i_dataA | i_dataB;

            AluOp_XOR:
                o_result = i_dataA ^ i_dataB;

            AluOp_SLL,
            AluOp_SRA,
            AluOp_SRL:
                o_result = shifter_result;

            AluOp_SLT:
                o_result = Data'(comparator_isLessSigned);

            AluOp_SLTU:
                o_result = Data'(comparator_isLessUnsigned);
        endcase
        // verilator lint_on CASEINCOMPLETE
    end

 endmodule
