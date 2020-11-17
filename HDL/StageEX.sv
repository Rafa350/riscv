// verilator lint_off IMPORTSTAR
import types::*;


module StageEX
#(
    parameter DATA_WIDTH = 32,
    parameter PC_WIDTH   = 32)
(
    // Senyals de control
    input  logic                  i_Clock,
    input  logic                  i_Reset,

    // Senyals d'entrada de la etapa anterior
    input  logic [6:0]            i_InstOP,
    input  logic [DATA_WIDTH-1:0] i_DataA,
    input  logic [DATA_WIDTH-1:0] i_DataB,
    input  logic [DATA_WIDTH-1:0] i_MemWrData,
    input  logic [PC_WIDTH-1:0]   i_PC,         // Adressa de la instruccio
    input  logic [4:0]            i_RegWrAddr,
    input  logic                  i_RegWrEnable,
    input  logic [1:0]            i_RegWrDataSel,
    input  logic                  i_MemWrEnable,
    input  AluOp                  i_AluControl,
    input  logic                  i_OperandASel,

    // Senyals d'entrada per forwading
    input  logic [4:0]            i_MEMFwdWriteReg,
    input  logic [DATA_WIDTH-1:0] i_WBFwdResult,

    // Senyals de sortida a la seguent etapa
    output logic [6:0]            o_InstOP,
    output logic [DATA_WIDTH-1:0] o_Result,
    output logic [4:0]            o_RegWrAddr,
    output logic                  o_RegWrEnable,
    output logic [1:0]            o_RegWrDataSel,
    output logic                  o_MemWrEnable,
    output logic [DATA_WIDTH-1:0] o_MemWrData);


    // -------------------------------------------------------------------
    // Selecciona el valor de la entrada A de la ALU
    // -------------------------------------------------------------------

    logic [DATA_WIDTH-1:0] OperandASelector_Output;
    
    Mux2To1 #(
        .WIDTH (DATA_WIDTH))
    OperandASelector (
        .i_Select (i_OperandASel),
        .i_Input0 (i_DataA),
        .i_Input1 (i_PC),
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

    logic [DATA_WIDTH-1:0] Alu_Result;
    
    Alu #(
        .WIDTH (DATA_WIDTH))
    Alu (
        .i_Op       (i_AluControl),
        .i_OperandA (OperandASelector_Output),
        .i_OperandB (OperandBSelector_Output),
        .o_Result   (Alu_Result));


    always_comb begin
        o_InstOP       = i_InstOP;
        o_Result       = Alu_Result;
        o_MemWrEnable  = i_MemWrEnable;
        o_MemWrData    = i_MemWrData;
        o_RegWrAddr    = i_RegWrAddr;
        o_RegWrEnable  = i_RegWrEnable;
        o_RegWrDataSel = i_RegWrDataSel;
    end

endmodule
