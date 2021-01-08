`include "RV.svh"


module StageEX
    import Types::*;
(
    input  Data        i_instIMM,            // Parametre IMM de la instruccio
    input  Data        i_dataA,              // Dades A dels registres
    input  Data        i_dataB,              // Dades B dels registres
    input  InstAddr    i_pc,                 // Adressa de la instruccio
    input  logic [1:0] i_operandASel,        // Seleccio del operand A de la ALU
    input  logic [1:0] i_operandBSel,        // Seleccio del operand B de la ALU
    input  AluOp       i_aluControl,         // Operacio a realitzar emb la ALU

    output Data        o_result,             // Resultat de la ALU
    output Data        o_dataB);             // Dades B


    // -----------------------------------------------------------------------
    // Selector del operand A per la ALU (RS1 o PC)
    // -----------------------------------------------------------------------

    Data operandASelector_output;

    // verilator lint_off PINMISSING
    Mux4To1 #(
        .WIDTH ($size(Data)))
    operandASelector (
        .i_select (i_operandASel),
        .i_input0 (i_dataA),
        .i_input1 ({{$size(Data)-$size(InstAddr){1'b0}}, i_pc}),
        .i_input2 ({DATA_WIDTH{1'b0}}),
        .o_output (operandASelector_output));
    // verilator lint_on PINMISSING


    // -----------------------------------------------------------------------
    // Selector del operand B per la ALU (RS2 o IMM)
    // -----------------------------------------------------------------------

    Data operandBSelector_output;

    // verilator lint_off PINMISSING
    Mux4To1 #(
        .WIDTH (DATA_WIDTH))
    operandBSelector (
        .i_select (i_operandBSel),
        .i_input0 (i_dataB),
        .i_input1 (i_instIMM),
        .i_input2 (4),
        .o_output (operandBSelector_output));
    // verilator lint_on PINMISSING


    // -------------------------------------------------------------------
    // Realitzacio dels calculs en la ALU
    // -------------------------------------------------------------------

    ALU 
    alu (
        .i_op       (i_aluControl),
        .i_operandA (operandASelector_output),
        .i_operandB (operandBSelector_output),
        .o_result   (o_result));

    assign o_dataB = i_dataB;

endmodule
