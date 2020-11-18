// verilator lint_off IMPORTSTAR
import types::*;


module StageEX
#(
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 32,
    parameter PC_WIDTH   = 32,
    parameter REG_WIDTH  = 5) 
(
    // Senyals de control
    input  logic                  i_Clock,
    input  logic                  i_Reset,

    // Senyals d'entrada de la etapa anterior
    input  logic [DATA_WIDTH-1:0] i_DataA,
    input  logic [DATA_WIDTH-1:0] i_DataB,
    input  logic [PC_WIDTH-1:0]   i_PC,         // Adressa de la instruccio
    input  AluOp                  i_AluControl,
    input  logic                  i_OperandASel,

    // Senyals d'entrada per forwading
    input  logic [4:0]            i_MEMFwdWriteReg,
    input  logic [DATA_WIDTH-1:0] i_WBFwdResult,

    // Senyals de sortida a la seguent etapa
    output logic [DATA_WIDTH-1:0] o_Result);


    // -------------------------------------------------------------------
    // Selecciona el valor de la entrada A de la ALU
    // -------------------------------------------------------------------

    logic [DATA_WIDTH-1:0] OperandASelector_Output;
    
    Mux2To1 #(
        .WIDTH (DATA_WIDTH))
    OperandASelector (
        .i_Select (i_OperandASel),
        .i_Input0 (i_DataA),
        .i_Input1 ({{DATA_WIDTH-PC_WIDTH{1'b0}}, i_PC}),
        .o_Output (OperandASelector_Output));


    // -------------------------------------------------------------------
    // Selecciona el valor de la entrada B de la ALU
    // -------------------------------------------------------------------

    logic [DATA_WIDTH-1:0] OperandBSelector_Output;
    
    Mux2To1 #(
        .WIDTH  (DATA_WIDTH))
    OperandBSelector (
        .i_Select (0),
        .i_Input0 (i_DataB),      ///// PENDENT DE REVISIO
        .i_Input1 (i_DataB),
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

endmodule
