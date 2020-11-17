// verilator lint_off IMPORTSTAR 
import types::*;


module StageEX 
#(
    parameter DATA_DBUS_WIDTH = 32,
    parameter ADDR_IBUS_WIDTH = 32)
(
    input  logic                       i_Clock,
    input  logic                       i_Reset,
    
    input  logic [ADDR_IBUS_WIDTH-1:0] i_PC,         // Adressa de la instruccio
    input  logic [DATA_DBUS_WIDTH-1:0] i_DataA,
    input  logic [DATA_DBUS_WIDTH-1:0] i_DataB,
    input  logic                       i_RegWrEnable,
    input  logic                       i_MemWrEnable,
    input  logic [1:0]                 i_DataToRegSel,
    input  AluOp                       i_AluControl,
    input  logic                       i_OperandASel,
    input  logic                       i_OperandBSel,
    input  logic [DATA_DBUS_WIDTH-1:0] i_InstIMM,
    input  logic [4:0]                 i_MEMFwdWriteReg,
    input  logic [DATA_DBUS_WIDTH-1:0] i_WBFwdResult,
    
    output logic [DATA_DBUS_WIDTH-1:0] o_WriteData,
    output logic [DATA_DBUS_WIDTH-1:0] o_AluResult,
    output logic                       o_RegWrEnable,
    output logic                       o_MemWrEnable,
    output logic [1:0]                 o_DataToRegSel,
    output logic [4:0]                 o_WriteReg);
    
    
    // -------------------------------------------------------------------
    // Selecciona el valor de la entrada A de la ALU
    //
    logic [DATA_DBUS_WIDTH-1:0] OperandASelector_Output;
    Mux2To1 #(
        .WIDTH (DATA_DBUS_WIDTH))
    OperandASelector (
        .i_Select (i_OperandASel),
        .i_Input0 (i_DataA),
        .i_Input1 (i_PC),
        .o_Output (OperandASelector_Output));
   
    // -------------------------------------------------------------------
    // Selecciona el valor de la entrada B de la ALU
    //
    logic [DATA_DBUS_WIDTH-1:0] OperandBSelector_Output;
    Mux2To1 #(
        .WIDTH  (DATA_DBUS_WIDTH))
    OperandBSelector (
        .i_Select (i_OperandBSel),
        .i_Input0 (i_DataB),
        .i_Input1 (i_InstIMM),
        .o_Output (OperandBSelector_Output));        


    // -------------------------------------------------------------------
    // Realitzacio dels calculs en la ALU
    //    
    logic [DATA_DBUS_WIDTH-1:0] Alu_Result;
    Alu #(
        .WIDTH (DATA_DBUS_WIDTH))
    Alu (
        .i_Op       (i_AluControl),
        .i_OperandA (OperandASelector_Output),
        .i_OperandB (OperandBSelector_Output),
        .o_Result   (Alu_Result));
    

    // -------------------------------------------------------------------
    // Actualitza els registres del pipeline
    //
    always_ff @(posedge i_Clock) begin
        o_AluResult    <= i_Reset ? 32'b0 : Alu_Result;       
        o_WriteData    <= i_Reset ? 32'b0 : i_DataB;
        o_RegWrEnable  <= i_Reset ? 1'b0  : i_RegWrEnable;
        o_MemWrEnable  <= i_Reset ? 1'b0  : i_MemWrEnable;
        o_DataToRegSel <= i_Reset ? 2'b00 : i_DataToRegSel;
        o_WriteReg     <= i_Reset ? 5'b0  : 0;
    end    
    
endmodule
