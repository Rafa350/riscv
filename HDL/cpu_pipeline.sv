// verilator lint_off IMPORTSTAR 


import types::*;


module cpu_pipeline
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
                                       o_MemWrData,
    output logic [ADDR_DBUS_WIDTH-1:0] o_MemAddr,
    output logic                       o_MemWrEnable,

    input  logic [DATA_IBUS_WIDTH-1:0] i_PgmInst,
    output logic [ADDR_IBUS_WIDTH-1:0] o_PgmAddr);
          
          
    // EX pipeline
    logic                       EX_is_zero;
    logic [DATA_DBUS_WIDTH-1:0] EX_AluOut;
    logic [DATA_DBUS_WIDTH-1:0] EX_WriteData;
    logic [4:0]                 EX_WriteReg;
    logic [ADDR_IBUS_WIDTH-1:0] EX_BranchAddr;
    logic                       EX_reg_we;
    logic                       EX_MemToReg;
    logic                       EX_mem_we;
    logic                       EX_pc_branch;                  
    logic                       EX_is_jump;
    logic                       EX_is_branch;
    
    // MEM pipeline
    logic [DATA_DBUS_WIDTH-1:0] MEM_AluOut;
    logic [DATA_DBUS_WIDTH-1:0] MEM_ReadData;
    logic [4:0]                 MEM_WriteReg;
    logic                       MEM_reg_we;
    logic                       MEM_MemToReg;
    
    // WB pipeline
    logic [DATA_DBUS_WIDTH-1:0] WB_Result;

       
    // Pipeline stage IF
    //
    logic [DATA_IBUS_WIDTH-1:0] IF_Inst;
    logic [ADDR_IBUS_WIDTH-1:0] IF_PCPlus4;

    stageIF #(
        .DATA_IBUS_WIDTH (DATA_IBUS_WIDTH),
        .ADDR_IBUS_WIDTH (ADDR_IBUS_WIDTH))
    IF (
        .i_Clock    (i_Clock),
        .i_Reset    (i_Reset),

        // Interface amb la memoria del programa
        .i_PgmInst  (i_PgmInst),
        .o_PgmAddr  (o_PgmAddr),

        // Entrades del pipeline
        .i_PCSrc    (EX_is_jump | (EX_is_zero & EX_is_branch)),
        .i_PCBranch (EX_pc_branch),
        
        // Sortides del pipeline
        .o_PCPlus4  (IF_PCPlus4),
        .o_Inst     (IF_Inst));
        
    // Pipeline stage ID
    //
    logic [DATA_DBUS_WIDTH-1:0] ID_DataA,
                                ID_DataB;
    logic [INDEX_WIDTH-1:0]     ID_InstRT;
    logic [INDEX_WIDTH-1:0]     ID_InstRD;
    logic [DATA_DBUS_WIDTH-1:0] ID_InstIMM;
    logic [ADDR_IBUS_WIDTH-1:0] ID_PCPlus4;
    logic                       ID_RegWrEnable;
    logic                       ID_MemToReg;
    logic                       ID_mem_we;
    logic                       ID_IsBranch;
    logic                       ID_IsJump;
    AluOp                       ID_AluControl;
    logic                       ID_AluSrcB;
    logic                       ID_RegDst;

    stageID #(
        .DATA_DBUS_WIDTH (DATA_DBUS_WIDTH),
        .DATA_IBUS_WIDTH (DATA_IBUS_WIDTH),
        .ADDR_IBUS_WIDTH (ADDR_IBUS_WIDTH))
    ID (
        .i_Clock       (i_Clock),
        .i_Reset       (i_Reset),

        // Entrades del pipeline
        .i_Inst        (IF_Inst),
        .i_PCPlus4     (IF_PCPlus4),
        .i_RegWrAddr   (MEM_WriteReg),
        .i_RegWrData   (WB_Result),
        .i_RegWrEnable (MEM_reg_we),

        // Sortides del pipeline        
        .o_PCPlus4     (ID_PCPlus4),
        .o_IsBranch    (ID_IsBranch),
        .o_IsJump      (ID_IsJump),
        .o_DataA       (ID_DataA),
        .o_DataB       (ID_DataB),
        .o_RegWrEnable (ID_RegWrEnable),
        .o_RegDst      (ID_RegDst),
        .o_MemWrEnable (ID_mem_we),
        .o_MemToReg    (ID_MemToReg),
        .o_InstRT      (ID_InstRT),
        .o_InstRD      (ID_InstRD),
        .o_InstIMM     (ID_InstIMM),
        .o_AluControl  (ID_AluControl),
        .o_AluSrcB     (ID_AluSrcB));
        
    // Pipeline stage EX
    //
    stageEX #(
        .DATA_DBUS_WIDTH (DATA_DBUS_WIDTH))
    stageEX(
        .i_Clock       (i_Clock),
        .i_Reset       (i_Reset),
        
        // Entrades del pipeline
        .i_pc_plus4    (ID_PCPlus4),
        .i_dataA      (ID_DataA),
        .i_dataB      (ID_DataB),
        .i_AluControl (ID_AluControl),
        .i_AluSrcB    (ID_AluSrcB),
        .i_reg_we     (ID_RegWrEnable),
        .i_mem_we     (ID_mem_we),
        .i_RegDst     (ID_RegDst),
        .i_MemToReg   (ID_MemToReg),
        .i_InstRT     (ID_InstRT),
        .i_InstRD     (ID_InstRD),
        .i_InstIMM    (ID_InstIMM),
        .i_is_branch  (ID_IsBranch),
        .i_is_jump    (ID_IsJump),
        
        // Sortides del pipeline
        .o_AluOut      (EX_AluOut),
        .o_reg_we      (EX_reg_we),
        .o_WriteReg    (EX_WriteReg),
        .o_MemWrEnable (EX_mem_we),
        .o_WriteData   (EX_WriteData),
        .o_MemToReg    (EX_MemToReg),
        .o_pc_branch   (EX_pc_branch),
        .o_is_zero     (EX_is_zero),
        .o_is_jump     (EX_is_jump),
        .o_is_branch   (EX_is_branch));
        
    // Pipeline stage MEM
    //
    stageMEM #(
        .DATA_DBUS_WIDTH (DATA_DBUS_WIDTH))
    stageMEM (
        .i_Clock           (i_Clock),
        .i_Reset           (i_Reset),
        
        // Interface amb la memoria RAM
        .o_mem_addr      (o_MemAddr),
        .i_mem_rdata     (i_MemRdData),
        .o_mem_wdata     (o_MemWrData),
        .o_mem_we        (o_MemWrEnable),
        
        // Entrades del pipeline
        .i_AluOut        (EX_AluOut),
        .i_WriteData     (EX_WriteData),
        .i_WriteReg      (EX_WriteReg),
        .i_reg_we        (EX_reg_we),
        .i_MemToReg      (EX_MemToReg),
        .i_mem_we        (EX_mem_we),
        
        // Sortides del pipeline
        .o_AluOut        (MEM_AluOut),
        .o_ReadData      (MEM_ReadData),
        .o_WriteReg      (MEM_WriteReg),
        .o_reg_we        (MEM_reg_we),
        .o_MemToReg      (MEM_MemToReg));
        
    // Pipeline stage WB
    //
    stageWB
    stageWB (
        .i_Clock (i_Clock),
        .i_Reset (i_Reset),
        
        // Entrades del pipeline
        .i_AluOut        (MEM_AluOut),
        .i_ReadData      (MEM_ReadData),
        
        // Sortides del pipeline
        .o_Result        (WB_Result));
          
endmodule


