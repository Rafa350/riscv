module BranchAlu
    import Types::*;
(
    input  logic [1:0] i_op,      // Operacio

    input  InstAddr    i_pc,      // PC
    input  Data        i_instIMM, // Valor inmediat de la isntruccio
    input  Data        i_regData, // Valor del registre base

    output InstAddr    o_pc);     // El resultat

    // Selecciona el valor base
    //
    InstAddr selBase_output;

    Mux2To1 #(
        .WIDTH ($size(InstAddr)))
    selBase (
        .i_select (i_op[1]),
        .i_input0 (i_pc),
        .i_input1 (i_regData[$size(InstAddr)-1:0]),
        .o_output (selBase_output));

    // Selecciona el offset
    //
    InstAddr selOffset_output;

    Mux2To1 #(
        .WIDTH ($size(InstAddr)))
    selOffset (
        .i_select (i_op[0]),
        .i_input0 (4),
        .i_input1 (i_instIMM[$size(InstAddr)-1:0]),
        .o_output (selOffset_output));

    // Suma els dos valors
    //
    HalfAdder #(
        .WIDTH ($size(InstAddr)))
    adder (
        .i_operandA (selBase_output),
        .i_operandB (selOffset_output),
        .o_result   (o_pc));

endmodule
