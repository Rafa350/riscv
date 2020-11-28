import types::AluOp;

module StageID
#(
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 32,
    parameter PC_WIDTH   = 32,
    parameter REG_WIDTH  = 5)
(
    // Senyals de control.
    input  logic                  i_Clock,             // Clock
    input  logic                  i_Reset,             // Reset

    // Senyals d'entrada de l'etapa anterior.
    input  logic [31:0]           i_Inst,              // Instruccio
    input  logic [PC_WIDTH-1:0]   i_PC,                // Adressa de la instruccio

    input  logic [REG_WIDTH-1:0]  i_EX_RegWrAddr,      // Registre per escriure
    input  logic                  i_EX_RegWrEnable,    // Habilita l'escriptura
    input  logic [1:0]            i_EX_RegWrDataSel,   // Seleccio de dades
    input  logic [DATA_WIDTH-1:0] i_EX_RegWrData,      // Dades a escriure en el registre
    input  logic [REG_WIDTH-1:0]  i_MEM_RegWrAddr,     // Registre per escriure
    input  logic                  i_MEM_RegWrEnable,   // Habilita l'escriptura
    input  logic [DATA_WIDTH-1:0] i_MEM_RegWrData,     // Dades a escriure
    input  logic [REG_WIDTH-1:0]  i_WB_RegWrAddr,      // Registre a escriure
    input  logic                  i_WB_RegWrEnable,    // Autoritzacio d'escriptura del registre
    input  logic [DATA_WIDTH-1:0] i_WB_RegWrData,      // El resultat a escriure

    output logic [6:0]            o_InstOP,            // Codi d'operacio de la instruccio
    output logic [REG_WIDTH-1:0]  o_InstRS1,           // Registre RS1 de la instruccio
    output logic [REG_WIDTH-1:0]  o_InstRS2,           // Registre RS2 de la instrruccio
    output logic [DATA_WIDTH-1:0] o_InstIMM,           // Valor inmediat de la instruccio
    output logic [DATA_WIDTH-1:0] o_DataA,             // Dades A (rs1)
    output logic [DATA_WIDTH-1:0] o_DataB,             // Dades B (rs2)
    output logic [REG_WIDTH-1:0]  o_RegWrAddr,         // Registre a escriure.
    output logic                  o_RegWrEnable,       // Habilita l'escriptura del registre
    output logic                  o_MemWrEnable,       // Habilita l'escritura en memoria
    output logic [1:0]            o_RegWrDataSel,      // Seleccio de les dades per escriure en el registre (rd)
    output logic                  o_OperandASel,       // Seleccio del valor A de la ALU
    output logic                  o_OperandBSel,       // Seleccio del valor B de la ALU
    output AluOp                  o_AluControl,        // Codi de control de la ALU
    output logic [PC_WIDTH-1:0]   o_PCNext);           // Nou valor de PC


    // ------------------------------------------------------------------------
    // Control del datapath.
    // Genera les senyals de control de les rutes de dades.
    // ------------------------------------------------------------------------

    AluOp       Ctrl_AluControl;   // Operacio de la ALU
    logic       Ctrl_RegWrEnable;  // Autoritza escriptura del regisres
    logic       Ctrl_MemWrEnable;  // Autoritza escritura en memoria
    logic [1:0] Ctrl_PCNextSel;    // Selector del seguent valor del PC
    logic [1:0] Ctrl_DataToRegSel; // Selector del les dades d'escriptura en el registre
    logic       Ctrl_OperandASel;  // Seleccio del operand A de la ALU
    logic       Ctrl_OperandBSel;  // Seleccio del operand B de la ALU

    Controller_RV32I
    Ctrl (
        .i_Inst         (i_Inst),             // La instruccio
        .i_IsEQ         (Comp_EQ),            // Indicador r1 == r2
        .i_IsLT         (Comp_LT),            // Indicador r1 < r2
        .o_MemWrEnable  (Ctrl_MemWrEnable),
        .o_RegWrEnable  (Ctrl_RegWrEnable),
        .o_RegWrDataSel (Ctrl_DataToRegSel),
        .o_AluControl   (Ctrl_AluControl),
        .o_OperandASel  (Ctrl_OperandASel),
        .o_OperandBSel  (Ctrl_OperandBSel),
        .o_PCNextSel    (Ctrl_PCNextSel));


    // ------------------------------------------------------------------------
    // Decodificador d'instruccions.
    // Separa les instruccions en els seus components, calculantr el valor
    // IMM de la instruccio en funcio del seu tipus
    // ------------------------------------------------------------------------

    logic [6:0]            Dec_InstOP;
    logic [REG_WIDTH-1:0]  Dec_InstRS1;
    logic [REG_WIDTH-1:0]  Dec_InstRS2;
    logic [REG_WIDTH-1:0]  Dec_InstRD;
    logic [DATA_WIDTH-1:0] Dec_InstIMM;

    Decoder_RV32I #(
        .REG_WIDTH (REG_WIDTH))
    Dec (
        .i_Inst (i_Inst),
        .o_OP   (Dec_InstOP),
        .o_RS1  (Dec_InstRS1),
        .o_RS2  (Dec_InstRS2),
        .o_RD   (Dec_InstRD),
        .o_IMM  (Dec_InstIMM));


    // ------------------------------------------------------------------------
    // Controlador de Forwarding. Selecciona el valor dels registres no
    // actualitzats, en les etapes posteriors del pipeline.
    // ------------------------------------------------------------------------

    logic [1:0] FwdCtrl_DataASel,
                FwdCtrl_DataBSel;

    ForwardController #(
        .REG_WIDTH (REG_WIDTH))
    FwdCtrl(
        .i_InstRS1         (Dec_InstRS1),
        .i_InstRS2         (Dec_InstRS2),
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
        .i_RdAddrA  (Dec_InstRS1),
        .o_RdDataA  (Regs_DataA),
        .i_RdAddrB  (Dec_InstRS2),
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
        .i_Op      (Ctrl_PCNextSel),
        .i_PC      (i_PC),
        .i_InstIMM (Dec_InstIMM),
        .i_RegData (Regs_DataA),
        .o_PC      (PCAlu_PC));


    always_comb begin
        o_InstOP       = Dec_InstOP;
        o_InstRS1      = Dec_InstRS1;
        o_InstRS2      = Dec_InstRS2;
        o_InstIMM      = Dec_InstIMM;
        o_DataA        = DataASelector_Output;
        o_DataB        = DataBSelector_Output;
        o_RegWrAddr    = Dec_InstRD;
        o_RegWrEnable  = Ctrl_RegWrEnable;
        o_RegWrDataSel = Ctrl_DataToRegSel;
        o_MemWrEnable  = Ctrl_MemWrEnable;
        o_OperandASel  = Ctrl_OperandASel;
        o_OperandBSel  = Ctrl_OperandBSel;
        o_AluControl   = Ctrl_AluControl;
        o_PCNext       = PCAlu_PC;
    end


endmodule






