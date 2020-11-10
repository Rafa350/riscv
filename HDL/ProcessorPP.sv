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
    
    input  logic [DATA_DBUS_WIDTH-1:0] i_MemRdData,
    output logic [DATA_DBUS_WIDTH-1:0] o_MemWrData,
    output logic [ADDR_DBUS_WIDTH-1:0] o_MemAddr,
    output logic                       o_MemWrEnable,

    input  logic [DATA_IBUS_WIDTH-1:0] i_PgmInst,
    output logic [ADDR_IBUS_WIDTH-1:0] o_PgmAddr);
          
                
    // Pipeline stage IF
    //
    logic [DATA_IBUS_WIDTH-1:0] IF_Inst;
    logic [ADDR_IBUS_WIDTH-1:0] IF_PCPlus4;

    stageIF #(
        .DATA_IBUS_WIDTH (DATA_IBUS_WIDTH),
        .ADDR_IBUS_WIDTH (ADDR_IBUS_WIDTH))
    IF (
        .i_Clock      (i_Clock),       // Clock
        .i_Reset      (i_Reset),       // Reset

        .i_PgmInst    (i_PgmInst),     // Adressa de programa
        .o_PgmAddr    (o_PgmAddr),     // Instruccio de programa

        .i_JumpEnable (ID_JumpEnable), // Habilita el salt
        .i_JumpAddr   (ID_JumpAddr),   // Adressa de salt
        
        .o_PCPlus4    (IF_PCPlus4),    // Adressa de la seguent instrccio
        .o_Inst       (IF_Inst));      // Instruccio actual
        
        
    // Pipeline stage ID
    //
    logic [DATA_DBUS_WIDTH-1:0] ID_DataA,
                                ID_DataB;
    logic [INDEX_WIDTH-1:0]     ID_InstRS;
    logic [INDEX_WIDTH-1:0]     ID_InstRT;
    logic [INDEX_WIDTH-1:0]     ID_InstRD;
    logic [DATA_DBUS_WIDTH-1:0] ID_InstIMM;
    logic                       ID_RegWrEnable;
    logic                       ID_MemToReg;
    logic                       ID_MemWrEnable;
    AluOp                       ID_AluControl;
    logic                       ID_AluSrcB;
    logic                       ID_RegDst;
    logic [ADDR_IBUS_WIDTH-1:0] ID_JumpAddr;
    logic                       ID_JumpEnable;

    stageID #(
        .DATA_DBUS_WIDTH (DATA_DBUS_WIDTH),
        .DATA_IBUS_WIDTH (DATA_IBUS_WIDTH),
        .ADDR_IBUS_WIDTH (ADDR_IBUS_WIDTH))
    ID (
        .i_Clock       (i_Clock),         // Clock
        .i_Reset       (i_Reset),         // Reset

        .i_Inst        (IF_Inst),         // Instruccio actual
        .i_PCPlus4     (IF_PCPlus4),      // Adressa de la seguent instrccio
        .i_RegWrAddr   (MEM_WriteReg),    // Adressa del registre on escriure
        .i_RegWrData   (WB_Result),       // Dades del registre on escriure
        .i_RegWrEnable (MEM_RegWrEnable), // Habilita escriure en el registre

        .o_DataA       (ID_DataA),        // Canal de dades A
        .o_DataB       (ID_DataB),        // Canal de dades B
        .o_RegWrEnable (ID_RegWrEnable),  // Habilita escriure en el registre
        .o_RegDst      (ID_RegDst),   
        .o_MemWrEnable (ID_MemWrEnable),  // Habilita escriure en memoria
        .o_MemToReg    (ID_MemToReg),
        .o_InstRS      (ID_InstRS),       // Parametre RS de la instruccio
        .o_InstRT      (ID_InstRT),       // Parametre RT de la instruccio
        .o_InstRD      (ID_InstRD),       // Parametre RD de la instruccio
        .o_InstIMM     (ID_InstIMM),      // Parametre IMM de la instrccui
        .o_AluControl  (ID_AluControl),
        .o_AluSrcB     (ID_AluSrcB),

        .o_JumpAddr    (ID_JumpAddr),     // Adressa de la propera instruccio per salt
        .o_JumpEnable  (ID_JumpEnable));  // Habilita el salt
        
        
    // Pipeline stage EX
    //
    logic [DATA_DBUS_WIDTH-1:0] EX_AluResult;
    logic [DATA_DBUS_WIDTH-1:0] EX_WriteData;
    logic [4:0]                 EX_WriteReg;
    logic                       EX_RegWrEnable;
    logic                       EX_MemToReg;
    logic                       EX_MemWrEnable;

    stageEX #(
        .DATA_DBUS_WIDTH (DATA_DBUS_WIDTH))
    EX (
        .i_Clock          (i_Clock),
        .i_Reset          (i_Reset),
        
        .i_DataA          (ID_DataA),
        .i_DataB          (ID_DataB),
        .i_AluControl     (ID_AluControl),
        .i_AluSrcB        (ID_AluSrcB),
        .i_RegWrEnable    (ID_RegWrEnable),
        .i_MemWrEnable    (ID_MemWrEnable),
        .i_RegDst         (ID_RegDst),
        .i_MemToReg       (ID_MemToReg),
        .i_InstRS         (ID_InstRS),
        .i_InstRT         (ID_InstRT),
        .i_InstRD         (ID_InstRD),
        .i_InstIMM        (ID_InstIMM),
        .i_MEMFwdWriteReg (MEM_WriteReg),
        .i_WBFwdResult    (WB_Result),
        
        .o_AluResult      (EX_AluResult),
        .o_RegWrEnable    (EX_RegWrEnable),
        .o_WriteReg       (EX_WriteReg),
        .o_MemWrEnable    (EX_MemWrEnable),
        .o_WriteData      (EX_WriteData),
        .o_MemToReg       (EX_MemToReg));
        
        
    // Pipeline stage MEM
    //
    logic [DATA_DBUS_WIDTH-1:0] MEM_AluResult;
    logic [DATA_DBUS_WIDTH-1:0] MEM_ReadData;
    logic [4:0]                 MEM_WriteReg;
    logic                       MEM_RegWrEnable;
    logic                       MEM_MemToReg;
    stageMEM #(
        .DATA_DBUS_WIDTH (DATA_DBUS_WIDTH))
    MEM (
        .i_Clock        (i_Clock),
        .i_Reset        (i_Reset),
        
        .o_mem_addr     (o_MemAddr),
        .i_mem_rdata    (i_MemRdData),
        .o_mem_wdata    (o_MemWrData),
        .o_mem_we       (o_MemWrEnable),
        
        .i_AluResult    (EX_AluResult),
        .i_WriteData    (EX_WriteData),
        .i_WriteReg     (EX_WriteReg),
        .i_RegWrEnable  (EX_RegWrEnable),
        .i_MemToReg     (EX_MemToReg),
        .i_MemWrEnable  (EX_MemWrEnable),
        
        .o_AluOut       (MEM_AluResult),
        .o_ReadData     (MEM_ReadData),
        .o_WriteReg     (MEM_WriteReg),
        .o_RegWrEnable  (MEM_RegWrEnable),
        .o_MemToReg     (MEM_MemToReg));
        
        
    // Pipeline stage WB
    //
    logic [DATA_DBUS_WIDTH-1:0] WB_Result;

    stageWB #(
        .DATA_DBUS_WIDTH (DATA_DBUS_WIDTH))
    WB (
        .i_Clock    (i_Clock),
        .i_Reset    (i_Reset),
        
        .i_MemToReg (MEM_MemToReg),
        .i_AluOut   (MEM_AluResult),
        .i_ReadData (MEM_ReadData),
        
        .o_Result   (WB_Result));
                  
endmodule


