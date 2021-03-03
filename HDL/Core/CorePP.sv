module CorePP
    import Config::*, Types::*;
(
    input logic    i_clock,  // Clock
    input logic    i_reset,  // Reset
    DataBus.master dataBus,  // Bus de dades
    InstBus.master instBus); // Bus d'instruccions


    // -------------------------------------------------------------------
    // Bloc de registres GPR (General Purpouse Registers)
    // -------------------------------------------------------------------

    Data gpr_rdataA;
    Data gpr_rdataB;

    GPRegisters
    gpr (
        .i_clock  (i_clock),
        .i_reset  (i_reset),
        .i_raddrA (ID_reg_raddrA),
        .i_raddrB (ID_reg_raddrB),
        .i_waddr  (WB_reg_waddr),
        .i_we     (WB_reg_we),
        .o_rdataA (gpr_rdataA),
        .o_rdataB (gpr_rdataB),
        .i_wdata  (WB_reg_wdata));


    // -------------------------------------------------------------------
    // Bloc de registres FPR (Floating Point Registers)
    // -------------------------------------------------------------------



    // -----------------------------------------------------------------------
    // Control de la logica del STALL/FLUSH
    // -----------------------------------------------------------------------

    logic stallCtrl_IFID_stall;
    logic stallCtrl_IDEX_stall;
    logic stallCtrl_IDEX_flush;
    logic stallCtrl_EXMEM_stall;
    logic stallCtrl_EXMEM_flush;
    logic stallCtrl_MEMWB_flush;

    StallController
    stallCtrl(
        .i_IF_hazard     (IF_hazard),
        .i_ID_hazard     (ID_hazard),
        .i_EX_hazard     (EX_hazard),
        .i_MEM_hazard    (MEM_hazard),
        .i_WB_hazard     (WB_hazard),
        .i_IFID_isValid  (IFID_isValid),
        .i_IDEX_isValid  (IDEX_isValid),
        .i_EXMEM_isValid (EXMEM_isValid),
        .i_MEMWB_isValid (MEMWB_isValid),
        .o_IFID_stall    (stallCtrl_IFID_stall),
        .o_IDEX_stall    (stallCtrl_IDEX_stall),
        .o_IDEX_flush    (stallCtrl_IDEX_flush),
        .o_EXMEM_stall   (stallCtrl_EXMEM_stall),
        .o_EXMEM_flush   (stallCtrl_EXMEM_flush),
        .o_MEMWB_flush   (stallCtrl_MEMWB_flush));


    // ------------------------------------------------------------------------
    // Stage IF
    // ------------------------------------------------------------------------

    Inst     IF_inst;
    InstAddr IF_pc;
    logic    IF_instCompressed;
    logic    IF_hazard;

    StageIF
    stageIF (
        .i_clock           (i_clock),           // Clock
        .i_reset           (i_reset),           // Reset
        .instBus           (instBus),           // Bus de la memoria cache d'instruccions
        .i_pcNext          (ID_pcNext),         // Adressa de salt
        .o_hazard          (IF_hazard),         // Indica hazard
        .o_inst            (IF_inst),           // Instruccio
        .o_instCompressed  (IF_instCompressed), // Indica si instruccio es comprimida
        .o_pc              (IF_pc));            // Adressa de la instruccio


    // ------------------------------------------------------------------------
    // Pipeline IF-ID
    // ------------------------------------------------------------------------

    logic    IFID_isValid;
    InstAddr IFID_pc;
    Inst     IFID_inst;
    logic    IFID_instCompressed;

    PipelineIFID
    pipelineIFID (
        .i_clock          (i_clock),
        .i_reset          (i_reset),
        .i_stall          (stallCtrl_IFID_stall),
        .i_isValid        (1'b1),
        .i_pc             (IF_pc),
        .i_inst           (IF_inst),
        .i_instCompressed (IF_instCompressed),
        .o_isValid        (IFID_isValid),
        .o_pc             (IFID_pc),
        .o_inst           (IFID_inst),
        .o_instCompressed (IFID_instCompressed));


    // ------------------------------------------------------------------------
    // Stage ID
    // ------------------------------------------------------------------------

    GPRAddr    ID_reg_raddrA;
    GPRAddr    ID_reg_raddrB;
    Data       ID_dataRS1;
    Data       ID_dataRS2;
    Data       ID_instIMM;
    CSRAddr    ID_instCSR;
    GPRAddr    ID_regWrAddr;
    logic      ID_regWrEnable;
    WrDataSel  ID_regWrDataSel;
    logic      ID_memWrEnable;
    logic      ID_memRdEnable;
    DataAccess ID_memAccess;
    logic      ID_memUnsigned;
    AluOp      ID_aluControl;
    MduOp      ID_mduControl;
    CsrOp      ID_csrControl;
    DataASel   ID_operandASel;
    DataBSel   ID_operandBSel;
    ResultSel  ID_resultSel;
    InstAddr   ID_pcNext;
    logic      ID_hazard;

    StageID
    stageID (
        .i_clock           (i_clock),
        .i_reset           (i_reset),
        .o_reg_raddrA      (ID_reg_raddrA),
        .o_reg_raddrB      (ID_reg_raddrB),
        .i_reg_rdataA      (gpr_rdataA),
        .i_reg_rdataB      (gpr_rdataB),
        .i_inst            (IFID_inst),           // Instruccio
        .i_instCompressed  (IFID_instCompressed), // La instruccio es comprimida
        .i_pc              (IFID_pc),             // Adressa de la instruccio
        .i_EX_isValid      (IDEX_isValid),        // Indica operacio valida en EX
        .i_EX_regWrAddr    (IDEX_regWrAddr),
        .i_EX_regWrEnable  (IDEX_regWrEnable),    // Indica operacio d'escriptura de registres en EX
        .i_EX_regWrDataSel (IDEX_regWrDataSel),
        .i_EX_regWrData    (EX_dataR),
        .i_EX_memRdEnable  (IDEX_memRdEnable),    // Indica si hi ha una operacio de lectura de memoria EX
        .i_MEM_isValid     (EXMEM_isValid),       // Indica opoeracio valida en MEM
        .i_MEM_regWrAddr   (EXMEM_regWrAddr),
        .i_MEM_regWrEnable (EXMEM_regWrEnable),
        .i_MEM_regWrData   (MEM_regWrData),       // El valor a escriure en el registre en MEM
        .i_MEM_memRdEnable (EXMEM_memRdEnable),   // Indica si hi ha una operacio de lectura de memoria MEM
        .i_WB_isValid      (MEMWB_isValid),       // Indica operacio valida en WB
        .i_WB_regWrAddr    (MEMWB_regWrAddr),     // Adressa del registre on escrure en WB
        .i_WB_regWrData    (MEMWB_regWrData),     // Dades del registre on escriure en WB
        .i_WB_regWrEnable  (MEMWB_regWrEnable),   // Habilita escriure en el registre en WB
        .o_dataRS1         (ID_dataRS1),          // Valor de RS1
        .o_dataRS2         (ID_dataRS2),          // Valor de RS2
        .o_instIMM         (ID_instIMM),          // Valor IMM
        .o_instCSR         (ID_instCSR),          // Valor CSR
        .o_hazard          (ID_hazard),           // Indica hazard
        .o_regWrAddr       (ID_regWrAddr),        // Registre per escriure
        .o_regWrEnable     (ID_regWrEnable),      // Habilita escriure en el registre
        .o_regWrDataSel    (ID_regWrDataSel),
        .o_memWrEnable     (ID_memWrEnable),      // Habilita l'escriptura en memoria
        .o_memRdEnable     (ID_memRdEnable),      // Habilita la lectura de la memoria
        .o_memAccess       (ID_memAccess),        // Tamany d'acces a la memoria
        .o_memUnsigned     (ID_memUnsigned),      // Lectura en memoria sense signe
        .o_aluControl      (ID_aluControl),
        .o_mduControl      (ID_mduControl),
        .o_csrControl      (ID_csrControl),
        .o_operandASel     (ID_operandASel),
        .o_operandBSel     (ID_operandBSel),
        .o_resultSel       (ID_resultSel),
        .o_pcNext          (ID_pcNext));          // Adressa de la propera instruccio


    // ------------------------------------------------------------------------
    // Pipeline ID-EX
    // ------------------------------------------------------------------------

    logic      IDEX_isValid;
    InstAddr   IDEX_pc;
    Data       IDEX_dataRS1;
    Data       IDEX_dataRS2;
    Data       IDEX_instIMM;
    CSRAddr    IDEX_instCSR;
    GPRAddr    IDEX_regWrAddr;
    logic      IDEX_regWrEnable;
    WrDataSel  IDEX_regWrDataSel;
    logic      IDEX_memWrEnable;
    logic      IDEX_memRdEnable;
    DataAccess IDEX_memAccess;
    logic      IDEX_memUnsigned;
    AluOp      IDEX_aluControl;
    MduOp      IDEX_mduControl;
    CsrOp      IDEX_csrControl;
    DataASel   IDEX_operandASel;
    DataBSel   IDEX_operandBSel;
    ResultSel  IDEX_resultSel;

    PipelineIDEX
    pipelineIDEX (
        .i_clock        (i_clock),
        .i_reset        (i_reset),
        .i_stall        (stallCtrl_IDEX_stall),
        .i_flush        (stallCtrl_IDEX_flush),
        .i_isValid      (IFID_isValid),
        .i_instIMM      (ID_instIMM),
        .i_instCSR      (ID_instCSR),
        .i_dataRS1      (ID_dataRS1),
        .i_dataRS2      (ID_dataRS2),
        .i_regWrAddr    (ID_regWrAddr),
        .i_regWrEnable  (ID_regWrEnable),
        .i_regWrDataSel (ID_regWrDataSel),
        .i_memWrEnable  (ID_memWrEnable),
        .i_memRdEnable  (ID_memRdEnable),
        .i_memAccess    (ID_memAccess),
        .i_memUnsigned  (ID_memUnsigned),
        .i_operandASel  (ID_operandASel),
        .i_operandBSel  (ID_operandBSel),
        .i_resultSel    (ID_resultSel),
        .i_aluControl   (ID_aluControl),
        .i_mduControl   (ID_mduControl),
        .i_csrControl   (ID_csrControl),
        .i_pc           (IFID_pc),
        .o_isValid      (IDEX_isValid),
        .o_instIMM      (IDEX_instIMM),
        .o_instCSR      (IDEX_instCSR),
        .o_dataRS1      (IDEX_dataRS1),
        .o_dataRS2      (IDEX_dataRS2),
        .o_regWrAddr    (IDEX_regWrAddr),
        .o_regWrEnable  (IDEX_regWrEnable),
        .o_regWrDataSel (IDEX_regWrDataSel),
        .o_memWrEnable  (IDEX_memWrEnable),
        .o_memRdEnable  (IDEX_memRdEnable),
        .o_memAccess    (IDEX_memAccess),
        .o_memUnsigned  (IDEX_memUnsigned),
        .o_aluControl   (IDEX_aluControl),
        .o_mduControl   (IDEX_mduControl),
        .o_csrControl   (IDEX_csrControl),
        .o_operandASel  (IDEX_operandASel),
        .o_operandBSel  (IDEX_operandBSel),
        .o_resultSel    (IDEX_resultSel),
        .o_pc           (IDEX_pc));


    // ------------------------------------------------------------------------
    // Stage EX
    // ------------------------------------------------------------------------

    Data  EX_dataR;
    Data  EX_dataB;
    logic EX_hazard;

    StageEX
    stageEX (
        .i_clock       (i_clock),
        .i_reset       (i_reset),
        .i_isValid     (IDEX_isValid),
        .i_dataRS1     (IDEX_dataRS1),
        .i_dataRS2     (IDEX_dataRS2),
        .i_instIMM     (IDEX_instIMM),
        .i_instCSR     (IDEX_instCSR),
        .i_pc          (IDEX_pc),
        .i_operandASel (IDEX_operandASel),
        .i_operandBSel (IDEX_operandBSel),
        .i_resultSel   (IDEX_resultSel),
        .i_aluControl  (IDEX_aluControl),
        .i_csrControl  (IDEX_csrControl),
        .i_evInstRet   (WB_evInstRet),
        .i_evMemRead   (MEM_evMemRead),
        .i_evMemWrite  (MEM_evMemWrite),
        .o_hazard      (EX_hazard),         // Indica hazard
        .o_dataR       (EX_dataR),
        .o_dataB       (EX_dataB));


    // ------------------------------------------------------------------------
    // Pipeline EX-MEM
    // ------------------------------------------------------------------------

    logic      EXMEM_isValid;
    InstAddr   EXMEM_pc;
    Data       EXMEM_dataR;
    Data       EXMEM_dataB;
    GPRAddr    EXMEM_regWrAddr;
    logic      EXMEM_regWrEnable;
    WrDataSel  EXMEM_regWrDataSel;
    logic      EXMEM_memWrEnable;
    logic      EXMEM_memRdEnable;
    DataAccess EXMEM_memAccess;
    logic      EXMEM_memUnsigned;

    PipelineEXMEM
    pipelineEXMEM (
        .i_clock        (i_clock),
        .i_reset        (i_reset),
        .i_stall        (stallCtrl_EXMEM_flush),
        .i_flush        (stallCtrl_EXMEM_stall),
        .i_isValid      (IDEX_isValid),
        .i_pc           (IDEX_pc),
        .i_dataR        (EX_dataR),
        .i_dataB        (EX_dataB),
        .i_memWrEnable  (IDEX_memWrEnable),
        .i_memRdEnable  (IDEX_memRdEnable),
        .i_memAccess    (IDEX_memAccess),
        .i_memUnsigned  (IDEX_memUnsigned),
        .i_regWrAddr    (IDEX_regWrAddr),
        .i_regWrEnable  (IDEX_regWrEnable),
        .i_regWrDataSel (IDEX_regWrDataSel),
        .o_isValid      (EXMEM_isValid),
        .o_pc           (EXMEM_pc),
        .o_dataR        (EXMEM_dataR),
        .o_dataB        (EXMEM_dataB),
        .o_memWrEnable  (EXMEM_memWrEnable),
        .o_memRdEnable  (EXMEM_memRdEnable),
        .o_memAccess    (EXMEM_memAccess),
        .o_memUnsigned  (EXMEM_memUnsigned),
        .o_regWrAddr    (EXMEM_regWrAddr),
        .o_regWrEnable  (EXMEM_regWrEnable),
        .o_regWrDataSel (EXMEM_regWrDataSel));


    // ------------------------------------------------------------------------
    // Stage MEM
    // ------------------------------------------------------------------------

    Data  MEM_regWrData;
    logic MEM_evMemRead;
    logic MEM_evMemWrite;
    logic MEM_hazard;

    StageMEM
    stageMEM (
        .i_clock        (i_clock),            // Clock
        .i_reset        (i_reset),            // Reseset
        .dataBus        (dataBus),            // Interficie amb la memoria de dades
        .i_isValid      (EXMEM_isValid),      // Indica operacio valida
        .i_dataR        (EXMEM_dataR),        // Adressa per escriure en memoria
        .i_dataB        (EXMEM_dataB),        // Dades per escriure
        .i_regWrDataSel (EXMEM_regWrDataSel), // Seleccio de dades d'escriptura en el registre
        .i_memWrEnable  (EXMEM_memWrEnable),  // Autoritzacio d'escriptura en memoria
        .i_memRdEnable  (EXMEM_memRdEnable),  // Autoritza la lectura de la memoria
        .i_memAccess    (EXMEM_memAccess),    // Tamany d'acces a la memoria
        .i_memUnsigned  (EXMEM_memUnsigned),  // Lectura de memoria sense signe
        .o_hazard       (MEM_hazard),         // Indica hazard
        .o_evMemRead    (MEM_evMemRead),      // Indica memoria lleigida
        .o_evMemWrite   (MEM_evMemWrite),     // Indica memoria escrita
        .o_regWrData    (MEM_regWrData));     // Dades per escriure en el registre


    // ------------------------------------------------------------------------
    // Pipeline MEM-WB
    // ------------------------------------------------------------------------

    logic   MEMWB_isValid;
    Data    MEMWB_regWrData;
    GPRAddr MEMWB_regWrAddr;
    logic   MEMWB_regWrEnable;

    PipelineMEMWB
    pipelineMEMWB (
        .i_clock       (i_clock),
        .i_reset       (i_reset),
        .i_flush       (stallCtrl_MEMWB_flush),
        .i_isValid     (EXMEM_isValid),
        .i_regWrAddr   (EXMEM_regWrAddr),
        .i_regWrEnable (EXMEM_regWrEnable),
        .i_regWrData   (MEM_regWrData),
        .o_isValid     (MEMWB_isValid),
        .o_regWrAddr   (MEMWB_regWrAddr),
        .o_regWrEnable (MEMWB_regWrEnable),
        .o_regWrData   (MEMWB_regWrData));


    // ------------------------------------------------------------------------
    // Stage WB
    // ------------------------------------------------------------------------

    GPRAddr WB_reg_waddr;
    Data    WB_reg_wdata;
    logic   WB_reg_we;
    logic   WB_hazard;
    logic   WB_evInstRet;

    StageWB
    stageWB (
        .i_clock       (i_clock),
        .i_reset       (i_reset),
        .o_reg_waddr   (WB_reg_waddr),
        .o_reg_we      (WB_reg_we),
        .o_reg_wdata   (WB_reg_wdata),
        .i_isValid     (MEMWB_isValid),     // Indica operacio valida
        .i_regWrAddr   (MEMWB_regWrAddr),   // Adressa del registre
        .i_regWrEnable (MEMWB_regWrEnable), // Habilila l'escriptura del registre
        .i_regWrData   (MEMWB_regWrData),   // Dades per escriure en el registre
        .o_hazard      (WB_hazard),
        .o_evInstRet   (WB_evInstRet));


    // ------------------------------------------------------------------------
    // Trace
    // Traçat de l'ultima intruccio executada.
    // Utilitza un pipeline separat, per simplificar, pero que opera
    // amb paralel amb el pprinmcipal
    // ------------------------------------------------------------------------

    generate
        if (RV_DEBUG_ON == 1) begin

            int dbgIFID_dbgTick;

            DebugPipelineIFID
            dbgPipelineIFID(
                .i_clock   (i_clock),
                .i_reset   (i_reset),
                .i_stall   (stallCtrl_IFID_stall),
                .i_dbgTick (dbgCtrl_tick),
                .o_dbgTick (dbgIFID_dbgTick));


            int  dbgIDEX_dbgTick;
            Inst dbgIDEX_dbgInst;

            DebugPipelineIDEX
            dbfPipelineIDEX(
                .i_clock   (i_clock),
                .i_reset   (i_reset),
                .i_stall   (stallCtrl_IDEX_stall),
                .i_flush   (stallCtrl_IDEX_flush),
                .i_dbgTick (dbgIFID_dbgTick),
                .i_dbgInst (IFID_inst),
                .o_dbgTick (dbgIDEX_dbgTick),
                .o_dbgInst (dbgIDEX_dbgInst));


            int  dbgEXMEM_dbgTick;
            Inst dbgEXMEM_dbgInst;

            DebugPipelineEXMEM
            dbgPipelineEXMEM(
                .i_clock   (i_clock),
                .i_reset   (i_reset),
                .i_stall   (stallCtrl_EXMEM_stall),
                .i_flush   (stallCtrl_EXMEM_flush),
                .i_dbgTick (dbgIDEX_dbgTick),
                .i_dbgInst (dbgIDEX_dbgInst),
                .o_dbgTick (dbgEXMEM_dbgTick),
                .o_dbgInst (dbgEXMEM_dbgInst));


            int        dbgMEMWB_dbgTick;
            InstAddr   dbgMEMWB_dbgPc;
            Inst       dbgMEMWB_dbgInst;
            DataAddr   dbgMEMWB_dbgMemWrAddr;
            logic      dbgMEMWB_dbgMemWrEnable;
            Data       dbgMEMWB_dbgMemWrData;
            DataAccess dbgMEMWB_dbgMemAccess;

            DebugPipelineMEMWB
            dbgMPipelineMEMWB(
                .i_clock          (i_clock),
                .i_reset          (i_reset),
                .i_flush          (stallCtrl_MEMWB_flush),
                .i_dbgTick        (dbgEXMEM_dbgTick),
                .i_dbgPc          (EXMEM_pc),
                .i_dbgInst        (dbgEXMEM_dbgInst),
                .i_dbgMemWrAddr   (EXMEM_dataR),
                .i_dbgMemWrEnable (EXMEM_memWrEnable),
                .i_dbgMemAccess   (EXMEM_memAccess),
                .i_dbgMemWrData   (EXMEM_dataB),
                .o_dbgTick        (dbgMEMWB_dbgTick),
                .o_dbgPc          (dbgMEMWB_dbgPc),
                .o_dbgInst        (dbgMEMWB_dbgInst),
                .o_dbgMemWrAddr   (dbgMEMWB_dbgMemWrAddr),
                .o_dbgMemWrEnable (dbgMEMWB_dbgMemWrEnable),
                .o_dbgMemAccess   (dbgMEMWB_dbgMemAccess),
                .o_dbgMemWrData   (dbgMEMWB_dbgMemWrData));


            int dbgCtrl_tick;

            DebugController
            dbgCtrl(
                .i_clock       (i_clock),
                .i_reset       (i_reset),
                .i_stall       (stallCtrl_IFID_stall),
                .i_tick        (dbgMEMWB_dbgTick),
                .i_isValid     (MEMWB_isValid),
                .i_pc          (dbgMEMWB_dbgPc),
                .i_inst        (dbgMEMWB_dbgInst),
                .i_regWrAddr   (MEMWB_regWrAddr),
                .i_regWrEnable (MEMWB_regWrEnable),
                .i_regWrData   (MEMWB_regWrData),
                .i_memWrAddr   (dbgMEMWB_dbgMemWrAddr),
                .i_memWrEnable (dbgMEMWB_dbgMemWrEnable),
                .i_memWrData   (dbgMEMWB_dbgMemWrData),
                .i_memAccess   (dbgMEMWB_dbgMemAccess),
                .o_tick        (dbgCtrl_tick));

        end
    endgenerate


endmodule
