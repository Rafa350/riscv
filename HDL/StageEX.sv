module StageEX
#(
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 32,
    parameter PC_WIDTH   = 32,
    parameter REG_WIDTH  = 5)
(
    input  logic [DATA_WIDTH-1:0] i_InstIMM,            // Parametre IMM de la instruccio
    input  logic [DATA_WIDTH-1:0] i_DataA,              // Dades A dels registres
    input  logic [DATA_WIDTH-1:0] i_DataB,              // Dades B dels registres
    input  logic [PC_WIDTH-1:0]   i_PC,                 // Adressa de la instruccio
    input  logic                  i_OperandASel,        // Seleccio del operand A de la ALU
    input  logic                  i_OperandBSel,        // Seleccio del operand B de la ALU
    input  Types::AluOp           i_AluControl,         // Operacio a realitzar emb la ALU

    output logic [DATA_WIDTH-1:0] o_Result,             // Resultat de la ALU
    output logic [DATA_WIDTH-1:0] o_DataB);             // Dades B


    import Types::*;


    // -----------------------------------------------------------------------
    // Selector del operand A per la ALU (RS1 o PC)
    // -----------------------------------------------------------------------

    logic [DATA_WIDTH-1:0] OperandASelector_Output;

    Mux2To1 #(
        .WIDTH (DATA_WIDTH))
    OperandASelector (
        .i_Select (i_OperandASel),
        .i_Input0 (i_DataA),
        .i_Input1 ({{DATA_WIDTH-PC_WIDTH{1'b0}}, i_PC}),
        .o_Output (OperandASelector_Output));


    // -----------------------------------------------------------------------
    // Selector del operand B per la ALU (RS2 o IMM)
    // -----------------------------------------------------------------------

    logic [DATA_WIDTH-1:0] OperandBSelector_Output;

    Mux2To1 #(
        .WIDTH (DATA_WIDTH))
    OperandBSelector (
        .i_Select (i_OperandBSel),
        .i_Input0 (i_DataB),
        .i_Input1 (i_InstIMM),
        .o_Output (OperandBSelector_Output));


    // -------------------------------------------------------------------
    // Realitzacio dels calculs en la ALU
    // -------------------------------------------------------------------

    Alu #(
        .WIDTH (DATA_WIDTH))
    Alu (
        .i_Op       (i_AluControl),
        .i_OperandA (OperandASelector_Output),
        .i_OperandB (OperandBSelector_Output),
        .o_Result   (o_Result));

    assign o_DataB = i_DataB;

endmodule
