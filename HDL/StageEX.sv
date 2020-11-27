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

    input  logic [DATA_WIDTH-1:0] i_InstIMM,            // Parametre IMM de la instruccio
    input  logic [REG_WIDTH-1:0]  i_InstRS1,            // Parametre RS1 de la instruccio
    input  logic [REG_WIDTH-1:0]  i_InstRS2,            // Parametre RS2 de la isntruccio
    input  logic [DATA_WIDTH-1:0] i_DataA,              // Dades A dels registres
    input  logic [DATA_WIDTH-1:0] i_DataB,              // Dades B dels registres
    input  logic [PC_WIDTH-1:0]   i_PC,                 // Adressa de la instruccio
    input  logic                  i_EXMEM_RegWrEnable,
    input  logic [REG_WIDTH-1:0]  i_EXMEM_RegWrAddr,
    input  logic [DATA_WIDTH-1:0] i_MEM_RegWrData,
    input  logic                  i_MEMWB_RegWrEnable,
    input  logic [REG_WIDTH-1:0]  i_MEMWB_RegWrAddr,
    input  logic [DATA_WIDTH-1:0] i_WB_RegWrData,
    input  logic                  i_OperandASel,        // Seleccio del operand A de la ALU
    input  logic                  i_OperandBSel,        // Seleccio del operand B de la ALU
    input  AluOp                  i_AluControl,         // Operacio a realitzar emb la ALU

    output logic [DATA_WIDTH-1:0] o_Result,             // Resultat de la ALU
    output logic [DATA_WIDTH-1:0] o_MemWrData);         // Dades a escriure en memoria


    // -------------------------------------------------------------------
    // Controlador de forwarding de la ALU. 
    // -------------------------------------------------------------------
    
    logic [1:0] EXFwdCtrl_DataASel, 
                EXFwdCtrl_DataBSel;
    logic [DATA_WIDTH-1:0] DataASelector_Output;
    logic [DATA_WIDTH-1:0] DataBSelector_Output;

    EXForwardController #(
        .REG_WIDTH (REG_WIDTH))
    EXFwdCtrl (
        .i_InstRS1            (i_InstRS1),
        .i_InstRS2            (i_InstRS2),
        .i_EXMEM_RegWrAddr    (i_EXMEM_RegWrAddr),
        .i_EXMEM_RegWrEnable  (i_EXMEM_RegWrEnable),
        .i_MEMWB_RegWrAddr    (i_MEMWB_RegWrAddr),
        .i_MEMWB_RegWrEnable  (i_MEMWB_RegWrEnable),
        .o_DataASel           (EXFwdCtrl_DataASel),
        .o_DataBSel           (EXFwdCtrl_DataBSel));
   
    // verilator lint_off PINMISSING
    Mux4To1 #(
        .WIDTH (DATA_WIDTH))
    DataASelector (
        .i_Select (EXFwdCtrl_DataASel),
        .i_Input0 (i_DataA),
        .i_Input1 (i_MEM_RegWrData),
        .i_Input2 (i_WB_RegWrData),
        .o_Output (DataASelector_Output));
    // verilator lint_on PINMISSING

    // verilator lint_off PINMISSING
    Mux4To1 #(
        .WIDTH (DATA_WIDTH))
    DataBSelector (
        .i_Select (EXFwdCtrl_DataBSel),
        .i_Input0 (i_DataB),
        .i_Input1 (i_MEM_RegWrData),
        .i_Input2 (i_WB_RegWrData),
        .o_Output (DataBSelector_Output));
    // verilator lint_on PINMISSING

    
    // -----------------------------------------------------------------------
    // Selector del operand A per la ALU (RS1 o PC)
    // -----------------------------------------------------------------------
    
    logic [DATA_WIDTH-1:0] OperandASelector_Output;

    Mux2To1 #(
        .WIDTH (DATA_WIDTH))
    OperandASelector (
        .i_Select (i_OperandASel),
        .i_Input0 (DataASelector_Output),
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
        .i_Input0 (DataBSelector_Output),
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
        
    assign o_MemWrData = DataBSelector_Output;

endmodule
