module StageID
#(
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 32,
    parameter PC_WIDTH   = 32,
    parameter REG_WIDTH  = 5)
(
    input  logic                  i_Clock,             // Clock
    input  logic                  i_Reset,             // Reset
    input  logic [31:0]           i_Inst,              // Instruccio
    input  logic [PC_WIDTH-1:0]   i_PC,                // Adressa de la instruccio
    input  logic [REG_WIDTH-1:0]  i_EX_RegWrAddr,      // Registre per escriure
    input  logic                  i_EX_RegWrEnable,    // Habilita l'escriptura en el registre
    input  logic [1:0]            i_EX_RegWrDataSel,   // Seleccio de dades
    input  logic [DATA_WIDTH-1:0] i_EX_RegWrData,      // Dades a escriure en el registre
    input  logic [REG_WIDTH-1:0]  i_MEM_RegWrAddr,     // Registre per escriure
    input  logic                  i_MEM_RegWrEnable,   // Habilita l'escriptura
    input  logic [DATA_WIDTH-1:0] i_MEM_RegWrData,     // Dades a escriure
    input  logic [REG_WIDTH-1:0]  i_WB_RegWrAddr,      // Registre a escriure
    input  logic                  i_WB_RegWrEnable,    // Autoritzacio d'escriptura del registre
    input  logic [DATA_WIDTH-1:0] i_WB_RegWrData,      // El resultat a escriure
    output logic [6:0]            o_InstOP,            // Codi d'operacio de la instruccio
    output logic [DATA_WIDTH-1:0] o_InstIMM,           // Valor inmediat de la instruccio
    output logic [DATA_WIDTH-1:0] o_DataA,             // Dades A (rs1)
    output logic [DATA_WIDTH-1:0] o_DataB,             // Dades B (rs2)
    output logic                  o_IsLoad,            // Indica instruccio Load
    output logic [REG_WIDTH-1:0]  o_RegWrAddr,         // Registre a escriure.
    output logic                  o_RegWrEnable,       // Habilita l'escriptura del registre
    output logic                  o_MemWrEnable,       // Habilita l'escritura en memoria
    output logic [1:0]            o_RegWrDataSel,      // Seleccio de les dades per escriure en el registre (rd)
    output logic                  o_OperandASel,       // Seleccio del valor A de la ALU
    output logic                  o_OperandBSel,       // Seleccio del valor B de la ALU
    output Types::AluOp           o_AluControl,        // Codi de control de la ALU
    output logic [PC_WIDTH-1:0]   o_PCNext);           // Nou valor de PC


    import Types::*;


    // ------------------------------------------------------------------------
    // Decodificador d'instruccions.
    // Separa les instruccions en els seus components, calculant el valor
    // IMM de la instruccio en funcio del seu tipus. Tambe indica el tipus
    // d'instruccio.
    // ------------------------------------------------------------------------

    logic [6:0]            Dec_OP;
    logic [REG_WIDTH-1:0]  Dec_RS1;
    logic [REG_WIDTH-1:0]  Dec_RS2;
    logic [REG_WIDTH-1:0]  Dec_RD;
    logic [DATA_WIDTH-1:0] Dec_IMM;
    logic                  Dec_IsLoad;
    logic                  Dec_IsALU;

    Decoder_RV32I #(
        .REG_WIDTH (REG_WIDTH))
    Dec (
        .i_Inst   (i_Inst),
        .o_OP     (Dec_OP),
        .o_RS1    (Dec_RS1),
        .o_RS2    (Dec_RS2),
        .o_RD     (Dec_RD),
        .o_IMM    (Dec_IMM),
        .o_IsLoad (Dec_IsLoad),
        .o_IsALU  (Dec_IsALU));


    // ------------------------------------------------------------------------
    // Controlador del datapath.
    // Genera les senyals de control de les rutes de dades.
    // ------------------------------------------------------------------------

    AluOp       DpCtrl_AluControl;   // Operacio de la ALU
    logic       DpCtrl_RegWrEnable;  // Autoritza escriptura del regisres
    logic       DpCtrl_MemWrEnable;  // Autoritza escritura en memoria
    logic [1:0] DpCtrl_PCNextSel;    // Selector del seguent valor del PC
    logic [1:0] DpCtrl_DataToRegSel; // Selector del les dades d'escriptura en el registre
    logic       DpCtrl_OperandASel;  // Seleccio del operand A de la ALU
    logic       DpCtrl_OperandBSel;  // Seleccio del operand B de la ALU

    DatapathController
    DpCtrl (
        .i_Inst         (i_Inst),             // La instruccio
        .i_IsEQ         (Comp_EQ),            // Indicador r1 == r2
        .i_IsLT         (Comp_LT),            // Indicador r1 < r2
        .o_MemWrEnable  (DpCtrl_MemWrEnable),
        .o_RegWrEnable  (DpCtrl_RegWrEnable),
        .o_RegWrDataSel (DpCtrl_DataToRegSel),
        .o_AluControl   (DpCtrl_AluControl),
        .o_OperandASel  (DpCtrl_OperandASel),
        .o_OperandBSel  (DpCtrl_OperandBSel),
        .o_PCNextSel    (DpCtrl_PCNextSel));
        
        
    // ------------------------------------------------------------------------
    // Controllador per stalling.
    // ------------------------------------------------------------------------

    /*StallController
    StallCtrl (
        .i_InstRS1     (Dec_RS1),
        .i_InstRS2     (Dec_RS2),
        .i_EX_IsLoad   (i_EX_IsLoad),
        .i_EX_RegAddr  (i_EX_RegWrAddr),
        .i_MEM_IsLoad  (i_MEM_IsLoad),
        .i_MEM_RegAddr (i_MEM_RegWrAddr));*/


    // ------------------------------------------------------------------------
    // Controlador de Forwarding. Selecciona el valor dels registres no
    // actualitzats, en les etapes posteriors del pipeline.
    // ------------------------------------------------------------------------

    logic [1:0] FwdCtrl_DataASel,
                FwdCtrl_DataBSel;

    ForwardController #(
        .REG_WIDTH (REG_WIDTH))
    FwdCtrl(
        .i_InstRS1         (Dec_RS1),
        .i_InstRS2         (Dec_RS2),
        .i_EX_RegWrAddr    (i_EX_RegWrAddr),
        .i_EX_RegWrEnable  (i_EX_RegWrEnable),
        .i_EX_RegWrDataSel (i_EX_RegWrDataSel),
        .i_MEM_RegWrAddr   (i_MEM_RegWrAddr),
        .i_MEM_RegWrEnable (i_MEM_RegWrEnable),
        .i_WB_RegWrAddr    (i_WB_RegWrAddr),
        .i_WB_RegWrEnable  (i_WB_RegWrEnable),
        .o_DataASel        (FwdCtrl_DataASel),
        .o_DataBSel        (FwdCtrl_DataBSel));


    // ------------------------------------------------------------------------
    // Comparador per les instruccions de salt.
    // Permet identificas les condicions de salt abans d'executar
    // la instruccio, calculant l'adressa de salt de la seguent instruccio
    // en IF.
    // ------------------------------------------------------------------------
    //
    logic Comp_EQ; // Indica A == B
    logic Comp_LT; // Indica A <= B

    // verilator lint_off PINMISSING
    Comparer #(
        .WIDTH (DATA_WIDTH))
    Comp(
        .i_InputA   (DataASelector_Output),
        .i_InputB   (DataBSelector_Output),
        .i_Unsigned (0),
        .o_EQ       (Comp_EQ),
        .o_LT       (Comp_LT));
    // verilator lint_on PINMISSING


    // ------------------------------------------------------------------------
    // Bloc de registres.
    // ------------------------------------------------------------------------

    logic [DATA_WIDTH-1:0] Regs_DataA;
    logic [DATA_WIDTH-1:0] Regs_DataB;

    RegisterFile #(
        .DATA_WIDTH (DATA_WIDTH),
        .ADDR_WIDTH (REG_WIDTH))
    Regs (
        .i_Clock    (i_Clock),
        .i_Reset    (i_Reset),
        .i_WrEnable (i_WB_RegWrEnable),
        .i_WrAddr   (i_WB_RegWrAddr),
        .i_WrData   (i_WB_RegWrData),
        .i_RdAddrA  (Dec_RS1),
        .o_RdDataA  (Regs_DataA),
        .i_RdAddrB  (Dec_RS2),
        .o_RdDataB  (Regs_DataB));


    // -----------------------------------------------------------------------
    // Seleccio de les dades del registre o de les etapes posteriors.
    // -----------------------------------------------------------------------

    logic [DATA_WIDTH-1:0] DataASelector_Output,
                           DataBSelector_Output;

    Mux4To1 #(
        .WIDTH (DATA_WIDTH))
    DataASelector (
        .i_Select (FwdCtrl_DataASel),
        .i_Input0 (Regs_DataA),
        .i_Input1 (i_EX_RegWrData),
        .i_Input2 (i_MEM_RegWrData),
        .i_Input3 (i_WB_RegWrData),
        .o_Output (DataASelector_Output));

    Mux4To1 #(
        .WIDTH (DATA_WIDTH))
    DataBSelector (
        .i_Select (FwdCtrl_DataBSel),
        .i_Input0 (Regs_DataB),
        .i_Input1 (i_EX_RegWrData),
        .i_Input2 (i_MEM_RegWrData),
        .i_Input3 (i_WB_RegWrData),
        .o_Output (DataBSelector_Output));


    // ------------------------------------------------------------------------
    // Evaluacio de l'adressa de salt
    // ------------------------------------------------------------------------

    logic [PC_WIDTH-1:0] PCAlu_PC;

    PCAlu #(
        .DATA_WIDTH (DATA_WIDTH),
        .PC_WIDTH   (PC_WIDTH))
    PCAlu (
        .i_Op      (DpCtrl_PCNextSel),
        .i_PC      (i_PC),
        .i_InstIMM (Dec_IMM),
        .i_RegData (Regs_DataA),
        .o_PC      (PCAlu_PC));


    always_comb begin
        o_InstOP       = Dec_OP;
        o_InstIMM      = Dec_IMM;
        o_DataA        = DataASelector_Output;
        o_DataB        = DataBSelector_Output;
        o_IsLoad       = Dec_IsLoad;
        o_RegWrAddr    = Dec_RD;
        o_RegWrEnable  = DpCtrl_RegWrEnable;
        o_RegWrDataSel = DpCtrl_DataToRegSel;
        o_MemWrEnable  = DpCtrl_MemWrEnable;
        o_OperandASel  = DpCtrl_OperandASel;
        o_OperandBSel  = DpCtrl_OperandBSel;
        o_AluControl   = DpCtrl_AluControl;
        o_PCNext       = PCAlu_PC;
    end


endmodule






