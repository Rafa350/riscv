// verilator lint_off IMPORTSTAR 
import types::*;


module ProcessorPP
#(
    parameter DATA_DBUS_WIDTH          = 32,
    parameter ADDR_DBUS_WIDTH          = 32,
    parameter DATA_IBUS_WIDTH          = 32,
    parameter ADDR_IBUS_WIDTH          = 32,
    parameter INDEX_WIDTH              = 5)
(
    input  logic                       i_Clock,
    input  logic                       i_Reset,

    output logic [ADDR_DBUS_WIDTH-1:0] o_MemAddr,     // Adressa
    output logic                       o_MemWrEnable, // Habilita la escriptura
    output logic [DATA_DBUS_WIDTH-1:0] o_MemWrData,   // Dades per escriure
    input  logic [DATA_DBUS_WIDTH-1:0] i_MemRdData,   // Dades lleigides
    
    output logic [ADDR_IBUS_WIDTH-1:0] o_PgmAddr,     // Adressa de la instruccio
    input  logic [DATA_IBUS_WIDTH-1:0] i_PgmInst);    // Instruccio
          
                         
    // Pipeline stage IF
    //
    logic [DATA_IBUS_WIDTH-1:0] IF_Inst;
    logic [ADDR_IBUS_WIDTH-1:0] IF_PC;

    StageIF #(
        .DATA_IBUS_WIDTH (DATA_IBUS_WIDTH),
        .ADDR_IBUS_WIDTH (ADDR_IBUS_WIDTH))
    IF (
        .i_Clock      (i_Clock),       // Clock
        .i_Reset      (i_Reset),       // Reset

        .i_PgmInst    (i_PgmInst),     // Instruccio de programa
        .o_PgmAddr    (o_PgmAddr),     // Adressa de programa

        .i_JumpEnable (ID_JumpEnable), // Habilita el salt
        .i_JumpAddr   (ID_JumpAddr),   // Adressa de salt       

        .o_PC         (IF_PC),         // Adressa de la instruccio
        .o_Inst       (IF_Inst));      // Instruccio 
        
        
    // Pipeline stage ID
    //
    logic [ADDR_IBUS_WIDTH-1:0] ID_PC;
    logic [DATA_DBUS_WIDTH-1:0] ID_DataA,
                                ID_DataB;
    logic [DATA_DBUS_WIDTH-1:0] ID_InstIMM;
    logic                       ID_RegWrEnable;
    logic [1:0]                 ID_DataToRegSel;
    logic                       ID_MemWrEnable;
    AluOp                       ID_AluControl;
    logic                       ID_OperandASel;
    logic                       ID_OperandBSel;
    logic [ADDR_IBUS_WIDTH-1:0] ID_JumpAddr;
    logic                       ID_JumpEnable;

    StageID #(
        .DATA_DBUS_WIDTH (DATA_DBUS_WIDTH),
        .DATA_IBUS_WIDTH (DATA_IBUS_WIDTH),
        .ADDR_IBUS_WIDTH (ADDR_IBUS_WIDTH))
    ID (
        .i_Clock        (i_Clock),         // Clock
        .i_Reset        (i_Reset),         // Reset

        .i_Inst         (IF_Inst),         // Instruccio 
        .i_PC           (IF_PC),           // Adressa de la instruccio
        .i_RegWrAddr    (MEM_WriteReg),    // Adressa del registre on escriure
        .i_RegWrData    (WB_Result),       // Dades del registre on escriure
        .i_RegWrEnable  (MEM_RegWrEnable), // Habilita escriure en el registre

        .o_PC           (ID_PC),           // Adresa de la instruccio
        .o_DataA        (ID_DataA),        // Canal de dades A
        .o_DataB        (ID_DataB),        // Canal de dades B
        .o_RegWrEnable  (ID_RegWrEnable),  // Habilita escriure en el registre
        .o_MemWrEnable  (ID_MemWrEnable),  // Habilita escriure en memoria
        .o_DataToRegSel (ID_DataToRegSel),
        .o_InstIMM      (ID_InstIMM),      // Parametre IMM de la instrccui
        .o_AluControl   (ID_AluControl),
        .o_OperandASel  (ID_OperandASel),  // Seleccio del operand A de la ALU
        .o_OperandBSel  (ID_OperandBSel),  // Seleccio del operand B de la ALU
        .o_JumpAddr     (ID_JumpAddr),     // Adressa de la propera instruccio per salt
        .o_JumpEnable   (ID_JumpEnable));  // Habilita el salt
        
        
    // Pipeline stage EX
    //
    logic [DATA_DBUS_WIDTH-1:0] EX_AluResult;
    logic [DATA_DBUS_WIDTH-1:0] EX_WriteData;
    logic [4:0]                 EX_WriteReg;
    logic                       EX_RegWrEnable;
    logic [1:0]                 EX_DataToRegSel;
    logic                       EX_MemWrEnable;

    StageEX #(
        .DATA_DBUS_WIDTH (DATA_DBUS_WIDTH))
    EX (
        .i_Clock          (i_Clock),
        .i_Reset          (i_Reset),
        
        .i_PC             (ID_PC),
        .i_DataA          (ID_DataA),
        .i_DataB          (ID_DataB),
        .i_AluControl     (ID_AluControl),
        .i_OperandASel    (ID_OperandASel),
        .i_OperandBSel    (ID_OperandBSel),
        .i_RegWrEnable    (ID_RegWrEnable),
        .i_MemWrEnable    (ID_MemWrEnable),
        .i_DataToRegSel   (ID_DataToRegSel),
        .i_InstIMM        (ID_InstIMM),
        .i_MEMFwdWriteReg (MEM_WriteReg),
        .i_WBFwdResult    (WB_Result),
        
        .o_AluResult      (EX_AluResult),
        .o_RegWrEnable    (EX_RegWrEnable),
        .o_WriteReg       (EX_WriteReg),
        .o_MemWrEnable    (EX_MemWrEnable),
        .o_WriteData      (EX_WriteData),
        .o_DataToRegSel   (EX_DataToRegSel));
        
        
    // Pipeline stage MEM
    //
    logic [DATA_DBUS_WIDTH-1:0] MEM_AluResult;
    logic [DATA_DBUS_WIDTH-1:0] MEM_ReadData;
    logic [4:0]                 MEM_WriteReg;
    logic                       MEM_RegWrEnable;
    logic [1:0]                 MEM_DataToRegSel;
    StageMEM #(
        .DATA_DBUS_WIDTH (DATA_DBUS_WIDTH))
    MEM (
        .i_Clock        (i_Clock),
        .i_Reset        (i_Reset),
        
        .o_MemAddr      (o_MemAddr),
        .i_MemRdData    (i_MemRdData),
        .o_MemWrData    (o_MemWrData),
        .o_MemWrEnable  (o_MemWrEnable),
        
        .i_AluResult    (EX_AluResult),
        .i_WriteData    (EX_WriteData),
        .i_WriteReg     (EX_WriteReg),
        .i_RegWrEnable  (EX_RegWrEnable),
        .i_DataToRegSel (EX_DataToRegSel),
        .i_MemWrEnable  (EX_MemWrEnable),
        
        .o_AluOut       (MEM_AluResult),
        .o_ReadData     (MEM_ReadData),
        .o_WriteReg     (MEM_WriteReg),
        .o_RegWrEnable  (MEM_RegWrEnable),
        .o_DataToRegSel (MEM_DataToRegSel));
        
        
    // Pipeline stage WB
    //
    logic [DATA_DBUS_WIDTH-1:0] WB_Result;

    StageWB #(
        .DATA_DBUS_WIDTH (DATA_DBUS_WIDTH))
    WB (
        .i_Clock        (i_Clock),
        .i_Reset        (i_Reset),
        
        .i_DataToRegSel (MEM_DataToRegSel),
        .i_AluOut       (MEM_AluResult),
        .i_ReadData     (MEM_ReadData),
        
        .o_Result       (WB_Result));
                  
endmodule


