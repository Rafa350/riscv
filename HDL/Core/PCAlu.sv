module PCAlu
    import Types::*;
(
    input  logic [1:0] i_op,      // Operacio

    input  InstAddr    i_pc,      // PC
    input  Data        i_instIMM, // Valor inmediat de la isntruccio
    input  Data        i_regData, // Valor del registre base

    output InstAddr    o_pc);     // El resultat

    InstAddr sel1_output;
    InstAddr sel2_output;

    Mux2To1 #(
        .WIDTH ($size(InstAddr)))
    sel1 (
        .i_select (i_op[1]),
        .i_input0 (i_pc),
        .i_input1 (i_regData[$size(InstAddr)-1:0]),
        .o_output (sel1_output));

    Mux2To1 #(
        .WIDTH ($size(InstAddr)))
    sel2 (
        .i_select (i_op[0]),
        .i_input0 (4),
        .i_input1 (i_instIMM[$size(InstAddr)-1:0]),
        .o_output (sel2_output));

    HalfAdder #(
        .WIDTH ($size(InstAddr)))
    adder (
        .i_operandA (sel1_output),
        .i_operandB (sel2_output),
        .o_result   (o_pc));

endmodule
