// verilator lint_off IMPORTSTAR 
import types::*;


module ProcessorPP
#(
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 32,
    parameter PC_WIDTH   = 32,
    parameter REG_WIDTH  = 5)
(
    input  logic                  i_Clock,
    input  logic                  i_Reset,

    output logic [ADDR_WIDTH-1:0] o_MemAddr,     // Adressa
    output logic                  o_MemWrEnable, // Habilita la escriptura
    output logic [DATA_WIDTH-1:0] o_MemWrData,   // Dades per escriure
    input  logic [DATA_WIDTH-1:0] i_MemRdData,   // Dades lleigides
    
    output logic [PC_WIDTH-1:0]   o_PgmAddr,     // Adressa de la instruccio
    input  logic [31:0]           i_PgmInst);    // Instruccio
          
    
    // ------------------------------------------------------------------------    
    // Stage IF
    // ------------------------------------------------------------------------
    
    logic [PC_WIDTH-1:0] IF_PC;
    logic [31:0]         IF_Inst;

    StageIF #(
        .DATA_WIDTH (DATA_WIDTH),
        .ADDR_WIDTH (ADDR_WIDTH),
        .PC_WIDTH   (PC_WIDTH),
        .REG_WIDTH  (REG_WIDTH))
    IF (
        .i_Clock   (i_Clock),   // Clock
        .i_Reset   (i_Reset),   // Reset

        .i_PgmInst (i_PgmInst), // Instruccio de programa
        .o_PgmAddr (o_PgmAddr), // Adressa de programa

        .i_PCNext  (ID_PCNext), // CTRL: Adressa de salt       

        .o_Inst    (IF_Inst),   // DATA: Instruccio 
        .o_PC      (IF_PC));    // CTRL: Adressa de la instruccio
        
        
    // ------------------------------------------------------------------------
    // Pipeline IFID
    // ------------------------------------------------------------------------
    
    logic [PC_WIDTH-1:0] IFID_PC;
    logic [31:0]         IFID_Inst;
    
    PipelineIFID #(
        .DATA_WIDTH (DATA_WIDTH),
        .ADDR_WIDTH (ADDR_WIDTH),
        .PC_WIDTH   (PC_WIDTH),
        .REG_WIDTH  (REG_WIDTH))
    IFID (
        .i_Clock (i_Clock),
        .i_Reset (i_Reset),
        
        .i_PC    (IF_PC),
        .i_Inst  (IF_Inst),
        
        .o_PC    (IFID_PC),
        .o_Inst  (IFID_Inst));
        
        
    // ------------------------------------------------------------------------    
    // Stage ID
    // ------------------------------------------------------------------------
    
    logic [DATA_WIDTH-1:0] ID_DataA,
                           ID_DataB;
    logic [DATA_WIDTH-1:0] ID_MemWrData;
    logic [6:0]            ID_InstOP;
    logic [REG_WIDTH-1:0]  ID_RegWrAddr;
    logic                  ID_RegWrEnable;
    logic [1:0]            ID_RegWrDataSel;
    logic                  ID_MemWrEnable;
    AluOp                  ID_AluControl;
    logic                  ID_OperandASel;
    logic [PC_WIDTH-1:0]   ID_PCNext;

    StageID #(
        .DATA_WIDTH (DATA_WIDTH),
        .ADDR_WIDTH (ADDR_WIDTH),
        .PC_WIDTH   (PC_WIDTH),
        .REG_WIDTH  (REG_WIDTH))
    ID (
        .i_Clock        (i_Clock),           // Clock
        .i_Reset        (i_Reset),           // Reset

        .i_Inst         (IFID_Inst),         // Instruccio 
        .i_PC           (IFID_PC),           // Adressa de la instruccio  
        .i_RegWrAddr    (MEMWB_RegWrAddr),   // Adressa del registre on escriure
        .i_RegWrData    (WB_RegWrData),      // Dades del registre on escriure
        .i_RegWrEnable  (MEMWB_RegWrEnable), // Habilita escriure en el registre

        .o_DataA        (ID_DataA),          // Dades A
        .o_DataB        (ID_DataB),          // Dades B
        .o_MemWrData    (ID_MemWrData),      // Valor per escriure en memoria
        .o_InstOP       (ID_InstOP),         // Instruccio
        .o_RegWrAddr    (ID_RegWrAddr),      // Registre per escriure
        .o_RegWrEnable  (ID_RegWrEnable),    // Habilita escriure en el registre
        .o_RegWrDataSel (ID_RegWrDataSel),
        .o_MemWrEnable  (ID_MemWrEnable),    // Habilita escriure en memoria
        .o_AluControl   (ID_AluControl),
        .o_OperandASel  (ID_OperandASel),    // Seleccio del operand A de la ALU
        .o_PCNext       (ID_PCNext));        // Adressa de la propera instruccio per salt
        

    // ------------------------------------------------------------------------
    // Pipeline ID-EX
    // ------------------------------------------------------------------------
    
    logic [PC_WIDTH-1:0]   IDEX_PC;
    logic [DATA_WIDTH-1:0] IDEX_DataA,
                           IDEX_DataB;
    logic [6:0]            IDEX_InstOP;
    logic [REG_WIDTH-1:0]  IDEX_RegWrAddr;
    logic                  IDEX_RegWrEnable;
    logic [1:0]            IDEX_RegWrDataSel;
    logic                  IDEX_MemWrEnable;
    logic [DATA_WIDTH-1:0] IDEX_MemWrData;
    AluOp                  IDEX_AluControl;

    PipelineIDEX #(
        .DATA_WIDTH (DATA_WIDTH),
        .ADDR_WIDTH (ADDR_WIDTH),
        .PC_WIDTH   (PC_WIDTH),
        .REG_WIDTH  (REG_WIDTH))
    IDEX (
        .i_Clock        (i_Clock),
        .i_Reset        (i_Reset),
        
        .i_InstOP       (ID_InstOP),
        .i_DataA        (ID_DataA),
        .i_DataB        (ID_DataB),
        .i_RegWrAddr    (ID_RegWrAddr),
        .i_RegWrEnable  (ID_RegWrEnable),
        .i_RegWrDataSel (ID_RegWrDataSel),
        .i_MemWrData    (ID_MemWrData),
        .i_MemWrEnable  (ID_MemWrEnable),
        .i_AluControl   (ID_AluControl),
        .i_PC           (IF_PC),
        
        .o_InstOP       (IDEX_InstOP),
        .o_DataA        (IDEX_DataA),
        .o_DataB        (IDEX_DataB),
        .o_RegWrAddr    (IDEX_RegWrAddr),
        .o_RegWrEnable  (IDEX_RegWrEnable),
        .o_RegWrDataSel (IDEX_RegWrDataSel),
        .o_MemWrData    (IDEX_MemWrData),
        .o_MemWrEnable  (IDEX_MemWrEnable),
        .o_AluControl   (IDEX_AluControl),
        .o_PC           (IDEX_PC));
   
   
    // ------------------------------------------------------------------------
    // Stage EX
    // ------------------------------------------------------------------------
    
    logic [DATA_WIDTH-1:0] EX_Result;

    StageEX #(
        .DATA_WIDTH (DATA_WIDTH),
        .ADDR_WIDTH (ADDR_WIDTH),
        .PC_WIDTH   (PC_WIDTH),
        .REG_WIDTH  (REG_WIDTH))
    EX (
        .i_Clock          (i_Clock),
        .i_Reset          (i_Reset),
        
        .i_DataA          (IDEX_DataA),
        .i_DataB          (IDEX_DataB),

        .i_PC             (IDEX_PC),
        .i_AluControl     (IDEX_AluControl),
        .i_OperandASel    (0),

        .i_MEMFwdWriteReg (MEMWB_RegWrAddr),
        .i_WBFwdResult    (WB_RegWrData),
        
        .o_Result         (EX_Result));
        
        
    // ------------------------------------------------------------------------
    // Pipeline EX-MEM
    // ------------------------------------------------------------------------
        
    logic [6:0]            EXMEM_InstOP;
    logic [DATA_WIDTH-1:0] EXMEM_Result;
    logic [DATA_WIDTH-1:0] EXMEM_MemWrData;
    logic [REG_WIDTH-1:0]  EXMEM_RegWrAddr;
    logic                  EXMEM_RegWrEnable;
    logic [1:0]            EXMEM_RegWrDataSel;
    logic                  EXMEM_MemWrEnable;

    PipelineEXMEM #(
        .DATA_WIDTH (DATA_WIDTH),
        .ADDR_WIDTH (ADDR_WIDTH),
        .PC_WIDTH   (PC_WIDTH),
        .REG_WIDTH  (REG_WIDTH))
    EXMEM (
        .i_Clock        (i_Clock),
        .i_Reset        (i_Reset),
        
        .i_Result       (EX_Result),

        .i_InstOP       (IDEX_InstOP),
        .i_MemWrEnable  (IDEX_MemWrEnable),
        .i_MemWrData    (IDEX_MemWrData),
        .i_RegWrAddr    (IDEX_RegWrAddr),
        .i_RegWrEnable  (IDEX_RegWrEnable),
        .i_RegWrDataSel (IDEX_RegWrDataSel),

        .o_Result       (EXMEM_Result),
        .o_InstOP       (EXMEM_InstOP),
        .o_MemWrEnable  (EXMEM_MemWrEnable),
        .o_MemWrData    (EXMEM_MemWrData),
        .o_RegWrAddr    (EXMEM_RegWrAddr),
        .o_RegWrEnable  (EXMEM_RegWrEnable),
        .o_RegWrDataSel (EXMEM_RegWrDataSel));        
        
        
    // ------------------------------------------------------------------------
    // Stage MEM
    // ------------------------------------------------------------------------
    
    logic [DATA_WIDTH-1:0] MEM_RegWrData;

    StageMEM #(
        .DATA_WIDTH (DATA_WIDTH),
        .ADDR_WIDTH (ADDR_WIDTH),
        .PC_WIDTH   (PC_WIDTH),
        .REG_WIDTH  (REG_WIDTH))
    MEM (
        .i_Clock        (i_Clock),
        .i_Reset        (i_Reset),
        
        .o_MemAddr      (o_MemAddr),
        .o_MemWrEnable  (o_MemWrEnable),
        .o_MemWrData    (o_MemWrData),
        .i_MemRdData    (i_MemRdData),
        
        .i_Result       (EXMEM_Result),
        .i_MemWrData    (EXMEM_MemWrData),
        .i_RegWrDataSel (EXMEM_RegWrDataSel),
        .i_MemWrEnable  (EXMEM_MemWrEnable),
        
        .o_RegWrData    (MEM_RegWrData));
        
   
    // ------------------------------------------------------------------------
    // Pipeline MEM-WB
    // ------------------------------------------------------------------------
    
    logic [6:0]            MEMWB_InstOP;
    logic [DATA_WIDTH-1:0] MEMWB_RegWrData;
    logic [REG_WIDTH-1:0]  MEMWB_RegWrAddr;
    logic                  MEMWB_RegWrEnable;

    PipelineMEMWB #(
        .DATA_WIDTH (DATA_WIDTH),
        .ADDR_WIDTH (ADDR_WIDTH),
        .PC_WIDTH   (PC_WIDTH),
        .REG_WIDTH  (REG_WIDTH))
    MEMWB (
        .i_Clock       (i_Clock),
        .i_Reset       (i_Reset),
        
        .i_InstOP      (EXMEM_InstOP),
        .i_RegWrAddr   (EXMEM_RegWrAddr),
        .i_RegWrEnable (EXMEM_RegWrEnable),
        .i_RegWrData   (MEM_RegWrData),
        
        .o_InstOP      (MEMWB_InstOP),
        .o_RegWrAddr   (MEMWB_RegWrAddr),
        .o_RegWrEnable (MEMWB_RegWrEnable),
        .o_RegWrData   (MEMWB_RegWrData));
        

    // ------------------------------------------------------------------------
    // Stage WB
    // ------------------------------------------------------------------------
    
    logic [DATA_WIDTH-1:0] WB_RegWrData;

    StageWB #(
        .DATA_WIDTH (DATA_WIDTH),
        .ADDR_WIDTH (ADDR_WIDTH),
        .PC_WIDTH   (PC_WIDTH),
        .REG_WIDTH  (REG_WIDTH))
    WB (
        .i_Clock        (i_Clock),
        .i_Reset        (i_Reset),
        
        .i_RegWrData    (MEMWB_RegWrData),
        
        .o_RegWrData    (WB_RegWrData));
                  
endmodule


