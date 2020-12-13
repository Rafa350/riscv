`include "RV.svh"

module ProcessorPP
    import Types::*;
#(
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 32,
    parameter PC_WIDTH   = 32,
    parameter REG_WIDTH  = 5)
(
    input  logic         i_Clock, // Clock
    input  logic         i_Reset, // Reset
    DataMemoryBus.Master DBus,    // Bus de la memoria de dades
    InstMemoryBus.Master IBus);   // Bus de la memoria d'instruccions

    
    // ------------------------------------------------------------------------
    // Debug
    // ------------------------------------------------------------------------

    logic [7:0] DbgCtrl_Tag;

    DebugController #(
        .DATA_WIDTH (DATA_WIDTH),
        .REG_WIDTH  (REG_WIDTH),
        .PC_WIDTH   (PC_WIDTH))
    DbgCtrl(
        .i_Clock         (i_Clock),
        .i_Reset         (i_Reset),
        .i_ExTag         (MEMWB_DbgTag),
        .i_ExPC          (MEMWB_DbgPC),
        .i_ExInst        (MEMWB_DbgInst),
        .i_ExRegWrAddr   (MEMWB_RegWrAddr),
        .i_ExRegWrData   (MEMWB_RegWrData),
        .i_ExRegWrEnable (MEMWB_RegWrEnable),
        .i_ExMemWrAddr   (0),
        .i_ExMemWrData   (0),
        .i_ExMemWrEnable (0),
        .o_Tag           (DbgCtrl_Tag));


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
        .IBus      (IBus),      // Bus de la memoria d'instruccio
        .i_PCNext  (ID_PCNext), // Adressa de salt
        .o_Inst    (IF_Inst),   // Instruccio
        .o_PC      (IF_PC));    // Adressa de la instruccio


    // ------------------------------------------------------------------------
    // Pipeline IFID
    // ------------------------------------------------------------------------

    logic [PC_WIDTH-1:0] IFID_PC;
    logic [31:0]         IFID_Inst;
    logic [7:0]          IFID_DbgTag;
    logic [PC_WIDTH-1:0] IFID_DbgPC;
    logic [31:0]         IFID_DbgInst;

    PipelineIFID #(
        .DATA_WIDTH (DATA_WIDTH),
        .ADDR_WIDTH (ADDR_WIDTH),
        .PC_WIDTH   (PC_WIDTH),
        .REG_WIDTH  (REG_WIDTH))
    IFID (
        .i_Clock   (i_Clock),
        .i_Reset   (i_Reset),
        .i_Stall   (ID_Bubble),
        .i_DbgTag  (DbgCtrl_Tag),
        .i_DbgPC   (IF_PC),
        .i_DbgInst (IF_Inst),
        .o_DbgTag  (IFID_DbgTag),
        .o_DbgPC   (IFID_DbgPC),
        .o_DbgInst (IFID_DbgInst),
        .i_PC      (IF_PC),
        .i_Inst    (IF_Inst),
        .o_PC      (IFID_PC),
        .o_Inst    (IFID_Inst));


    // ------------------------------------------------------------------------
    // Stage ID
    // ------------------------------------------------------------------------

    logic [DATA_WIDTH-1:0] ID_DataA,
                           ID_DataB;
    logic [6:0]            ID_InstOP;
    logic [DATA_WIDTH-1:0] ID_InstIMM;
    logic                  ID_IsLoad;
    logic [REG_WIDTH-1:0]  ID_RegWrAddr;
    logic                  ID_RegWrEnable;
    logic [1:0]            ID_RegWrDataSel;
    logic                  ID_MemWrEnable;
    AluOp                  ID_AluControl;
    logic [1:0]            ID_OperandASel;
    logic [1:0]            ID_OperandBSel;
    logic [PC_WIDTH-1:0]   ID_PCNext;
    logic                  ID_Bubble;

    logic [REG_WIDTH-1:0]  ID_RequiredRS1;
    logic [REG_WIDTH-1:0]  ID_RequiredRS2;

    StageID #(
        .DATA_WIDTH (DATA_WIDTH),
        .ADDR_WIDTH (ADDR_WIDTH),
        .PC_WIDTH   (PC_WIDTH),
        .REG_WIDTH  (REG_WIDTH))
    ID (
        .i_Clock           (i_Clock),           // Clock
        .i_Reset           (i_Reset),           // Reset
        .i_Inst            (IFID_Inst),         // Instruccio
        .i_PC              (IFID_PC),           // Adressa de la instruccio
        .i_EX_RegWrAddr    (IDEX_RegWrAddr),
        .i_EX_RegWrEnable  (IDEX_RegWrEnable),
        .i_EX_RegWrDataSel (IDEX_RegWrDataSel),
        .i_EX_RegWrData    (EX_Result),
        .i_EX_IsLoad       (IDEX_IsLoad),       // Indica si hi ha una instruccio Load en EX
        .i_MEM_RegWrAddr   (EXMEM_RegWrAddr),
        .i_MEM_RegWrEnable (EXMEM_RegWrEnable),
        .i_MEM_RegWrData   (EXMEM_Result),      // El valor a escriure en el registre
        .i_MEM_IsLoad      (EXMEM_IsLoad),      // Indica si hi ha una instruccio Load en MEM
        .i_WB_RegWrAddr    (MEMWB_RegWrAddr),   // Adressa del registre on escriure
        .i_WB_RegWrData    (MEMWB_RegWrData),   // Dades del registre on escriure
        .i_WB_RegWrEnable  (MEMWB_RegWrEnable), // Habilita escriure en el registre
        .o_DataA           (ID_DataA),          // Dades A
        .o_DataB           (ID_DataB),          // Dades B
        .o_InstOP          (ID_InstOP),         // Instruccio OP
        .o_InstIMM         (ID_InstIMM),
        .o_IsLoad          (ID_IsLoad),
        .o_Bubble          (ID_Bubble),         // Indica si cal generar bombolla
        .o_RegWrAddr       (ID_RegWrAddr),      // Registre per escriure
        .o_RegWrEnable     (ID_RegWrEnable),    // Habilita escriure en el registre
        .o_RegWrDataSel    (ID_RegWrDataSel),
        .o_MemWrEnable     (ID_MemWrEnable),    // Habilita escriure en memoria
        .o_AluControl      (ID_AluControl),
        .o_OperandASel     (ID_OperandASel),
        .o_OperandBSel     (ID_OperandBSel),
        .o_PCNext          (ID_PCNext));        // Adressa de la propera instruccio per salt


    // ------------------------------------------------------------------------
    // Pipeline ID-EX
    // ------------------------------------------------------------------------

    logic [PC_WIDTH-1:0]   IDEX_PC;
    logic [DATA_WIDTH-1:0] IDEX_DataA,
                           IDEX_DataB;
    logic [6:0]            IDEX_InstOP;
    logic [DATA_WIDTH-1:0] IDEX_InstIMM;
    logic [REG_WIDTH-1:0]  IDEX_RegWrAddr;
    logic                  IDEX_RegWrEnable;
    logic [1:0]            IDEX_RegWrDataSel;
    logic                  IDEX_MemWrEnable;
    logic                  IDEX_IsLoad;
    AluOp                  IDEX_AluControl;
    logic [1:0]            IDEX_OperandASel;
    logic [1:0]            IDEX_OperandBSel;
    logic [7:0]            IDEX_DbgTag;
    logic [PC_WIDTH-1:0]   IDEX_DbgPC;
    logic [31:0]           IDEX_DbgInst;

    PipelineIDEX #(
        .DATA_WIDTH (DATA_WIDTH),
        .ADDR_WIDTH (ADDR_WIDTH),
        .PC_WIDTH   (PC_WIDTH),
        .REG_WIDTH  (REG_WIDTH))
    IDEX (
        .i_Clock        (i_Clock),
        .i_Reset        (i_Reset),
        .i_Flush        (ID_Bubble),
        .i_DbgTag       (IFID_DbgTag),
        .i_DbgPC        (IFID_DbgPC),
        .i_DbgInst      (IFID_DbgInst),
        .o_DbgTag       (IDEX_DbgTag),
        .o_DbgPC        (IDEX_DbgPC),
        .o_DbgInst      (IDEX_DbgInst),
        .i_InstOP       (ID_InstOP),
        .i_InstIMM      (ID_InstIMM),
        .i_DataA        (ID_DataA),
        .i_DataB        (ID_DataB),
        .i_RegWrAddr    (ID_RegWrAddr),
        .i_RegWrEnable  (ID_RegWrEnable),
        .i_RegWrDataSel (ID_RegWrDataSel),
        .i_MemWrEnable  (ID_MemWrEnable),
        .i_IsLoad       (ID_IsLoad),
        .i_OperandASel  (ID_OperandASel),
        .i_OperandBSel  (ID_OperandBSel),
        .i_AluControl   (ID_AluControl),
        .i_PC           (IFID_PC),
        .o_InstOP       (IDEX_InstOP),
        .o_InstIMM      (IDEX_InstIMM),
        .o_DataA        (IDEX_DataA),
        .o_DataB        (IDEX_DataB),
        .o_RegWrAddr    (IDEX_RegWrAddr),
        .o_RegWrEnable  (IDEX_RegWrEnable),
        .o_RegWrDataSel (IDEX_RegWrDataSel),
        .o_MemWrEnable  (IDEX_MemWrEnable),
        .o_IsLoad       (IDEX_IsLoad),
        .o_AluControl   (IDEX_AluControl),
        .o_OperandASel  (IDEX_OperandASel),
        .o_OperandBSel  (IDEX_OperandBSel),
        .o_PC           (IDEX_PC));


    // ------------------------------------------------------------------------
    // Stage EX
    // ------------------------------------------------------------------------

    logic [DATA_WIDTH-1:0] EX_Result;
    logic [DATA_WIDTH-1:0] EX_DataB;

    StageEX #(
        .DATA_WIDTH (DATA_WIDTH),
        .ADDR_WIDTH (ADDR_WIDTH),
        .PC_WIDTH   (PC_WIDTH),
        .REG_WIDTH  (REG_WIDTH))
    EX (
        .i_DataA              (IDEX_DataA),
        .i_DataB              (IDEX_DataB),
        .i_InstIMM            (IDEX_InstIMM),
        .i_PC                 (IDEX_PC),
        .i_OperandASel        (IDEX_OperandASel),
        .i_OperandBSel        (IDEX_OperandBSel),
        .i_AluControl         (IDEX_AluControl),
        .o_Result             (EX_Result),
        .o_DataB              (EX_DataB));


    // ------------------------------------------------------------------------
    // Pipeline EX-MEM
    // ------------------------------------------------------------------------

    logic [PC_WIDTH-1:0]   EXMEM_PC;
    logic [6:0]            EXMEM_InstOP;
    logic [DATA_WIDTH-1:0] EXMEM_Result;
    logic [DATA_WIDTH-1:0] EXMEM_DataB;
    logic [REG_WIDTH-1:0]  EXMEM_RegWrAddr;
    logic                  EXMEM_RegWrEnable;
    logic [1:0]            EXMEM_RegWrDataSel;
    logic                  EXMEM_MemWrEnable;
    logic                  EXMEM_IsLoad;
    logic [7:0]            EXMEM_DbgTag;
    logic [PC_WIDTH-1:0]   EXMEM_DbgPC;
    logic [31:0]           EXMEM_DbgInst;

    PipelineEXMEM #(
        .DATA_WIDTH (DATA_WIDTH),
        .ADDR_WIDTH (ADDR_WIDTH),
        .PC_WIDTH   (PC_WIDTH),
        .REG_WIDTH  (REG_WIDTH))
    EXMEM (
        .i_Clock        (i_Clock),
        .i_Reset        (i_Reset),
        .i_Flush        (0),        
        .i_DbgTag       (IDEX_DbgTag),
        .i_DbgInst      (IDEX_DbgInst),
        .i_DbgPC        (IDEX_DbgPC),
        .o_DbgTag       (EXMEM_DbgTag),
        .o_DbgPC        (EXMEM_DbgPC),
        .o_DbgInst      (EXMEM_DbgInst),        
        .i_PC           (IDEX_PC),
        .i_Result       (EX_Result),
        .i_DataB        (EX_DataB),
        .i_InstOP       (IDEX_InstOP),
        .i_MemWrEnable  (IDEX_MemWrEnable),
        .i_RegWrAddr    (IDEX_RegWrAddr),
        .i_RegWrEnable  (IDEX_RegWrEnable),
        .i_RegWrDataSel (IDEX_RegWrDataSel),
        .i_IsLoad       (IDEX_IsLoad),        
        .o_PC           (EXMEM_PC),
        .o_Result       (EXMEM_Result),
        .o_DataB        (EXMEM_DataB),
        .o_InstOP       (EXMEM_InstOP),
        .o_MemWrEnable  (EXMEM_MemWrEnable),
        .o_RegWrAddr    (EXMEM_RegWrAddr),
        .o_RegWrEnable  (EXMEM_RegWrEnable),
        .o_RegWrDataSel (EXMEM_RegWrDataSel),
        .o_IsLoad       (EXMEM_IsLoad));


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
        .DBus           (DBus),
        .i_PC           (EXMEM_PC),
        .i_Result       (EXMEM_Result),
        .i_DataB        (EXMEM_DataB),
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
    logic [7:0]            MEMWB_DbgTag;
    logic [PC_WIDTH-1:0]   MEMWB_DbgPC;
    logic [31:0]           MEMWB_DbgInst;

    PipelineMEMWB #(
        .DATA_WIDTH (DATA_WIDTH),
        .ADDR_WIDTH (ADDR_WIDTH),
        .PC_WIDTH   (PC_WIDTH),
        .REG_WIDTH  (REG_WIDTH))
    MEMWB (
        .i_Clock       (i_Clock),
        .i_Reset       (i_Reset),
        .i_Flush       (0),
        .i_DbgTag      (EXMEM_DbgTag),
        .i_DbgPC       (EXMEM_DbgPC),
        .i_DbgInst     (EXMEM_DbgInst),
        .o_DbgTag      (MEMWB_DbgTag),
        .o_DbgPC       (MEMWB_DbgPC),
        .o_DbgInst     (MEMWB_DbgInst),
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
    // Es teoric, en la practica no te cap implementacio, ja que es la part
    // d'escriptura en els registres, que es troben en el stage ID.
    // ------------------------------------------------------------------------


endmodule


