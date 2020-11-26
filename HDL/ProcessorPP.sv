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
    // Generador de'etiquetes de depuracio.
    // ------------------------------------------------------------------------
    
    logic [2:0] DbgTag;
    
    DebugTagGenerator DebugTagGenerator(
        .i_Clock (i_Clock),
        .i_Reset (i_Reset),
        .o_Tag   (DbgTag));
          
    
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
    logic [2:0]          IFID_DbgTag;
    
    PipelineIFID #(
        .DATA_WIDTH (DATA_WIDTH),
        .ADDR_WIDTH (ADDR_WIDTH),
        .PC_WIDTH   (PC_WIDTH),
        .REG_WIDTH  (REG_WIDTH))
    IFID (
        .i_Clock  (i_Clock),
        .i_Reset  (i_Reset),
                
        .i_DbgTag (DbgTag),
        .o_DbgTag (IFID_DbgTag),
        
        .i_PC     (IF_PC),
        .i_Inst   (IF_Inst),
        
        .o_PC    (IFID_PC),
        .o_Inst  (IFID_Inst));
        
        
    // ------------------------------------------------------------------------    
    // Stage ID
    // ------------------------------------------------------------------------
    
    logic [DATA_WIDTH-1:0] ID_DataA,
                           ID_DataB;
    logic [6:0]            ID_InstOP;
    logic [REG_WIDTH-1:0]  ID_InstRS1;
    logic [REG_WIDTH-1:0]  ID_InstRS2;
    logic [DATA_WIDTH-1:0] ID_InstIMM;
    logic [REG_WIDTH-1:0]  ID_RegWrAddr;
    logic                  ID_RegWrEnable;
    logic [1:0]            ID_RegWrDataSel;
    logic                  ID_MemWrEnable;
    AluOp                  ID_AluControl;
    logic                  ID_OperandASel;
    logic                  ID_OperandBSel;
    logic [PC_WIDTH-1:0]   ID_PCNext;
    
    logic [REG_WIDTH-1:0]  ID_RequiredRS1;
    logic [REG_WIDTH-1:0]  ID_RequiredRS2;

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
        .i_RegWrData    (MEMWB_RegWrData),   // Dades del registre on escriure
        .i_RegWrEnable  (MEMWB_RegWrEnable), // Habilita escriure en el registre

        .o_DataA        (ID_DataA),          // Dades A
        .o_DataB        (ID_DataB),          // Dades B
        .o_InstOP       (ID_InstOP),         // Instruccio OP
        .o_InstRS1      (ID_InstRS1),
        .o_InstRS2      (ID_InstRS2),
        .o_InstIMM      (ID_InstIMM),
        .o_RegWrAddr    (ID_RegWrAddr),      // Registre per escriure
        .o_RegWrEnable  (ID_RegWrEnable),    // Habilita escriure en el registre
        .o_RegWrDataSel (ID_RegWrDataSel),
        .o_MemWrEnable  (ID_MemWrEnable),    // Habilita escriure en memoria
        .o_AluControl   (ID_AluControl),
        .o_OperandASel  (ID_OperandASel),
        .o_OperandBSel  (ID_OperandBSel),   
        .o_PCNext       (ID_PCNext));        // Adressa de la propera instruccio per salt
        

    // ------------------------------------------------------------------------
    // Pipeline ID-EX
    // ------------------------------------------------------------------------
    
    logic [PC_WIDTH-1:0]   IDEX_PC;
    logic [DATA_WIDTH-1:0] IDEX_DataA,
                           IDEX_DataB;
    logic [6:0]            IDEX_InstOP;
    logic [REG_WIDTH-1:0]  IDEX_InstRS1;
    logic [REG_WIDTH-1:0]  IDEX_InstRS2;
    logic [DATA_WIDTH-1:0] IDEX_InstIMM;
    logic [REG_WIDTH-1:0]  IDEX_RegWrAddr;
    logic                  IDEX_RegWrEnable;
    logic [1:0]            IDEX_RegWrDataSel;
    logic                  IDEX_MemWrEnable;
    AluOp                  IDEX_AluControl;
    logic                  IDEX_OperandASel;
    logic                  IDEX_OperandBSel;
    logic [2:0]            IDEX_DbgTag;

    PipelineIDEX #(
        .DATA_WIDTH (DATA_WIDTH),
        .ADDR_WIDTH (ADDR_WIDTH),
        .PC_WIDTH   (PC_WIDTH),
        .REG_WIDTH  (REG_WIDTH))
    IDEX (
        .i_Clock        (i_Clock),
        .i_Reset        (i_Reset),
        .i_Flush        (0),
        
        .i_DbgTag       (IFID_DbgTag),
        .o_DbgTag       (IDEX_DbgTag),

        .i_InstOP       (ID_InstOP),
        .i_InstRS1      (ID_InstRS1),
        .i_InstRS2      (ID_InstRS2),
        .i_InstIMM      (ID_InstIMM),
        .i_DataA        (ID_DataA),
        .i_DataB        (ID_DataB),
        .i_RegWrAddr    (ID_RegWrAddr),
        .i_RegWrEnable  (ID_RegWrEnable),
        .i_RegWrDataSel (ID_RegWrDataSel),
        .i_MemWrEnable  (ID_MemWrEnable),
        .i_OperandASel  (ID_OperandASel),
        .i_OperandBSel  (ID_OperandBSel),
        .i_AluControl   (ID_AluControl),
        .i_PC           (IFID_PC),
        
        .o_InstOP       (IDEX_InstOP),
        .o_InstRS1      (IDEX_InstRS1),
        .o_InstRS2      (IDEX_InstRS2),
        .o_InstIMM      (IDEX_InstIMM),
        .o_DataA        (IDEX_DataA),
        .o_DataB        (IDEX_DataB),
        .o_RegWrAddr    (IDEX_RegWrAddr),
        .o_RegWrEnable  (IDEX_RegWrEnable),
        .o_RegWrDataSel (IDEX_RegWrDataSel),
        .o_MemWrEnable  (IDEX_MemWrEnable),
        .o_AluControl   (IDEX_AluControl),
        .o_OperandASel  (IDEX_OperandASel),
        .o_OperandBSel  (IDEX_OperandBSel),
        .o_PC           (IDEX_PC));
   
   
    // ------------------------------------------------------------------------
    // Stage EX
    // ------------------------------------------------------------------------
    
    logic [DATA_WIDTH-1:0] EX_Result;
    logic [DATA_WIDTH-1:0] EX_MemWrData;
    
    StageEX #(
        .DATA_WIDTH (DATA_WIDTH),
        .ADDR_WIDTH (ADDR_WIDTH),
        .PC_WIDTH   (PC_WIDTH),
        .REG_WIDTH  (REG_WIDTH))
    EX (
        .i_Clock             (i_Clock),
        .i_Reset             (i_Reset),
        
        .i_DataA             (IDEX_DataA),
        .i_DataB             (IDEX_DataB),
        .i_InstIMM           (IDEX_InstIMM),
        .i_InstRS1           (IDEX_InstRS1),
        .i_InstRS2           (IDEX_InstRS2),
        .i_PC                (IDEX_PC),
        .i_OperandASel       (IDEX_OperandASel),
        .i_OperandBSel       (IDEX_OperandBSel),
        .i_AluControl        (IDEX_AluControl),
        .i_EXMEM_RegWrAddr   (EXMEM_RegWrAddr),
        .i_EXMEM_RegWrEnable (EXMEM_RegWrEnable),
        .i_EXMEM_Data        (EXMEM_Result),
        .i_MEMWB_RegWrAddr   (MEMWB_RegWrAddr),
        .i_MEMWB_RegWrEnable (MEMWB_RegWrEnable),
        .i_MEMWB_Data        (MEMWB_RegWrData),

        .o_Result            (EX_Result),
        .o_MemWrData         (EX_MemWrData));
        
        
    // ------------------------------------------------------------------------
    // Pipeline EX-MEM
    // ------------------------------------------------------------------------
        
    logic [PC_WIDTH-1:0]   EXMEM_PC;
    logic [6:0]            EXMEM_InstOP;
    logic [DATA_WIDTH-1:0] EXMEM_Result;
    logic [DATA_WIDTH-1:0] EXMEM_MemWrData;
    logic [REG_WIDTH-1:0]  EXMEM_RegWrAddr;
    logic                  EXMEM_RegWrEnable;
    logic [1:0]            EXMEM_RegWrDataSel;
    logic                  EXMEM_MemWrEnable;
    logic [2:0]            EXMEM_DbgTag;

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
        .o_DbgTag       (EXMEM_DbgTag),
        
        .i_PC           (IDEX_PC),
        .i_Result       (EX_Result),

        .i_InstOP       (IDEX_InstOP),
        .i_MemWrEnable  (IDEX_MemWrEnable),
        .i_MemWrData    (EX_MemWrData),
        .i_RegWrAddr    (IDEX_RegWrAddr),
        .i_RegWrEnable  (IDEX_RegWrEnable),
        .i_RegWrDataSel (IDEX_RegWrDataSel),

        .o_PC           (EXMEM_PC),
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
        
        .i_PC           (EXMEM_PC),
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
    logic [2:0]            MEMWB_DbgTag;

    PipelineMEMWB #(
        .DATA_WIDTH (DATA_WIDTH),
        .ADDR_WIDTH (ADDR_WIDTH),
        .PC_WIDTH   (PC_WIDTH),
        .REG_WIDTH  (REG_WIDTH))
    MEMWB (
        .i_Clock       (i_Clock),
        .i_Reset       (i_Reset),
        .i_Flush        (0),
        
        .i_DbgTag      (EXMEM_DbgTag),
        .o_DbgTag      (MEMWB_DbgTag),
        
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


