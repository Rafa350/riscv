module ALU (
    input  CoreDefs::AluOp      i_op,
    input  ProcessorDefs::Data  i_dataA,
    input  ProcessorDefs::Data  i_dataB,
    output ProcessorDefs::Data  o_result);


    ProcessorDefs::Data adder_result;
    ProcessorDefs::Data shifter_result;
    logic               comparator_isLessUnsigned;
    logic               comparator_isLessSigned;


    // verilator lint_off PINMISSING
    Adder #(
        .WIDTH ($size(ProcessorDefs::Data)))
    adder(
        .i_operandA (i_dataA),
        .i_operandB (i_dataB ^ {$size(ProcessorDefs::Data){i_op == CoreDefs::AluOp_SUB}}),
        .i_carry    (i_op == CoreDefs::AluOp_SUB),
        .o_result   (adder_result));
    // verilator lint_on PINMISSING


    // verilator lint_off PINMISSING
    FullComparer #(
        .WIDTH ($size(ProcessorDefs::Data)))
    comparator (
        .i_dataA          (i_dataA),
        .i_dataB          (i_dataB),
        .o_isLessUnsigned (comparator_isLessUnsigned),
        .o_isLessSigned   (comparator_isLessSigned));
    // verilator lint_on PINMISSING


    Shifter #(
        .WIDTH ($size(ProcessorDefs::Data)))
    shifter (
        .i_data       (i_dataA),
        .i_bits       (i_dataB[4:0]),
        .i_left       (i_op == CoreDefs::AluOp_SLL),
        .i_rotate     (0),
        .i_arithmetic (i_op == CoreDefs::AluOp_SRA),
        .o_data       (shifter_result));


    // verilator lint_off LATCH 
    always_comb begin

        // verilator lint_off CASEINCOMPLETE
        unique case (i_op)

            CoreDefs::AluOp_ADD,
            CoreDefs::AluOp_SUB:
                o_result = adder_result;

            CoreDefs::AluOp_AND:
                o_result = i_dataA & i_dataB;

            CoreDefs::AluOp_OR:
                o_result = i_dataA | i_dataB;

            CoreDefs::AluOp_XOR:
                o_result = i_dataA ^ i_dataB;

            CoreDefs::AluOp_SLL,
            CoreDefs::AluOp_SRA,
            CoreDefs::AluOp_SRL:
                o_result = shifter_result;

            CoreDefs::AluOp_SLT:
                o_result = ProcessorDefs::Data'(comparator_isLessSigned);

            CoreDefs::AluOp_SLTU:
                o_result = ProcessorDefs::Data'(comparator_isLessUnsigned);
        endcase
        // verilator lint_on CASEINCOMPLETE
    end

 endmodule
