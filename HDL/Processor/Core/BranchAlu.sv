module BranchAlu
    import ProcessorDefs::*;
(
    input  logic [1:0] i_op,      // Operacio
    input  InstAddr    i_pc,      // PC
    input  Data        i_instIMM, // Valor inmediat de la instruccio
    input  Data        i_regData, // Valor del registre base
    output InstAddr    o_pc);     // El resultat


    InstAddr operandA;
    InstAddr operandB;


    assign operandA = i_op[1] ? i_regData : i_pc;
    assign operandB = i_op[0] ? i_instIMM : InstAddr'(4);

    assign o_pc = operandA + operandB;

    /*
    // verilator lint_off PINMISSING
    Adder #(
        .WIDTH ($size(InstAddr)))
    adder (
        .i_operandA (operandA),
        .i_operandB (operandB),
        .i_carry    (1'b0),
        .o_result   (o_pc));
    // verilator lint_on PINMISSING
    */
endmodule
