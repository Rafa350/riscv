// verilator lint_off IMPORTSTAR 
import types::*;


module stageEX 
#(
    parameter DATA_DBUS_WIDTH = 32,
    parameter ADDR_IBUS_WIDTH = 32)
(
    input  logic                       i_Clock,
    input  logic                       i_Reset,
    
    input  logic [DATA_DBUS_WIDTH-1:0] i_DataA,
    input  logic [DATA_DBUS_WIDTH-1:0] i_DataB,
    input  logic                       i_RegWrEnable,
    input  logic                       i_MemWrEnable,
    input  logic                       i_RegDst,
    input  logic                       i_MemToReg,
    input  AluOp                       i_AluControl,
    input  logic                       i_AluSrcB,
    input  logic [4:0]                 i_InstRS,
    input  logic [4:0]                 i_InstRT,
    input  logic [4:0]                 i_InstRD,
    input  logic [DATA_DBUS_WIDTH-1:0] i_InstIMM,
    input  logic [4:0]                 i_MEMFwdWriteReg,
    input  logic [DATA_DBUS_WIDTH-1:0] i_WBFwdResult,
    
    output logic [DATA_DBUS_WIDTH-1:0] o_WriteData,
    output logic [DATA_DBUS_WIDTH-1:0] o_AluResult,
    output logic                       o_RegWrEnable,
    output logic                       o_MemWrEnable,
    output logic                       o_MemToReg,
    output logic [4:0]                 o_WriteReg);
    
   
    // -------------------------------------------------------------------
    // Selecciona el valor de la entradas B de la alu
    //
    logic [DATA_DBUS_WIDTH-1:0] Mux1_Output;
    Mux2To1 #(
        .WIDTH  (DATA_DBUS_WIDTH))
    Mux1 (
        .i_Select (i_AluSrcB),
        .i_Input0 (i_DataB),
        .i_Input1 (i_InstIMM),
        .o_Output (Mux1_Output));
    
    
    // -------------------------------------------------------------------
    // Selecciona el registre d'escriptura del resultat
    //
    logic [4:0] Mux2_Output;
    Mux2To1 #(
        .WIDTH (5))
    Mux2 (
        .i_Select (i_RegDst),
        .i_Input0 (i_InstRT),
        .i_Input1 (i_InstRD),
        .o_Output (Mux2_Output));
        
        
    // -------------------------------------------------------------------
    // Seleccio de l'entrada A de la ALU directe o forward
    //
    // verilator lint_off UNUSED
    logic [DATA_DBUS_WIDTH-1:0] FwdA_Output;
    // verilator lint_on UNUSED
    // verilator lint_off PINMISSING
    Mux4To1 #(
        .WIDTH (DATA_DBUS_WIDTH))
    FwdA (
        .i_Select (FCtrl_DataASelect),
        .i_Input0 (i_DataA),
        .i_Input1 (i_WBFwdResult),
        .i_Input2 (o_AluResult),
        .o_Output (FwdA_Output)
    );
    // verilator lint_on PINMISSING
       
       
    // -------------------------------------------------------------------
    // Seleccio de l'entrada B de la ALU directe o forward
    //
    // verilator lint_off UNUSED
    logic [DATA_DBUS_WIDTH-1:0] FwdB_Output;
    // verilator lint_on UNUSED
    // verilator lint_off PINMISSING
    Mux4To1 #(
        .WIDTH (DATA_DBUS_WIDTH))
    FwdB (
        .i_Select (FCtrl_DataBSelect),
        .i_Input0 (Mux1_Output),
        .i_Input1 (i_WBFwdResult),
        .i_Input2 (o_AluResult),
        .o_Output (FwdB_Output)
    );
    // verilator lint_on PINMISSING


    // -------------------------------------------------------------------
    // Realitzacio dels calculs en la ALU
    //    
    logic [DATA_DBUS_WIDTH-1:0] Alu_Result;
    // verilator lint_off UNUSED
    logic                       Alu_Zero;
    logic                       Alu_Carry;
    // verilator lint_on UNUSED
    // verilator lint_off PINMISSING
    Alu #(
        .WIDTH (DATA_DBUS_WIDTH))
    Alu (
        .i_Op       (i_AluControl),
        .i_OperandA (i_DataA),
        .i_OperandB (Mux1_Output),
        .i_Carry    (0),
        .o_Result   (Alu_Result),
        .o_Zero     (Alu_Zero),
        .o_Carry    (Alu_Carry));
    // verilator lint_on PINMISSING
    
    
    // -------------------------------------------------------------------
    // Control de forward
    //
    logic [1:0] FCtrl_DataASelect,
                FCtrl_DataBSelect;
    ForwardController
    FCtrl (
        .i_IDFwdInstRS    (i_InstRS),
        .i_IDFwdInstRT    (i_InstRT),
        .i_EXFwdWriteReg  (o_WriteReg),
        .i_MEMFwdWriteReg (i_MEMFwdWriteReg),
        .o_DataASelect    (FCtrl_DataASelect),
        .o_DataBSelect    (FCtrl_DataBSelect));
    

    // -------------------------------------------------------------------
    // Actualitza els registres del pipeline
    //
    always_ff @(posedge i_Clock) begin
        o_AluResult   <= i_Reset ? 32'b0 : Alu_Result;       
        o_WriteData   <= i_Reset ? 32'b0 : i_DataB;
        o_RegWrEnable <= i_Reset ? 1'b0  : i_RegWrEnable;
        o_MemWrEnable <= i_Reset ? 1'b0  : i_MemWrEnable;
        o_MemToReg    <= i_Reset ? 1'b0  : i_MemToReg;
        o_WriteReg    <= i_Reset ? 5'b0  : Mux2_Output;
    end    
    
endmodule
