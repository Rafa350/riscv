// verilator lint_off IMPORTSTAR
import types::*;


module StageEX
#(
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 32,
    parameter PC_WIDTH   = 32,
    parameter REG_WIDTH  = 5) 
(
    input  logic                  i_Clock,
    input  logic                  i_Reset,

    input  logic [DATA_WIDTH-1:0] i_DataA,
    input  logic [DATA_WIDTH-1:0] i_DataB,
    input  logic [DATA_WIDTH-1:0] i_InstIMM,    
    input  logic [PC_WIDTH-1:0]   i_PC,         // Adressa de la instruccio
    input  logic                  i_OperandBSel,
    input  AluOp                  i_AluControl,

    output logic [DATA_WIDTH-1:0] o_Result,
    output logic [DATA_WIDTH-1:0] o_MemWrData);

    
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
        .i_OperandA (i_DataA),
        .i_OperandB (OperandBSelector_Output),
        .o_Result   (o_Result));
        
    assign o_MemWrData = i_DataB;

endmodule
