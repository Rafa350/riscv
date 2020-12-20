`include "RV.svh"


module StageID
    import Types::*;
(
    // Senyals de control
    input  logic       i_clock,             // Clock
    input  logic       i_reset,             // Reset

    input  Inst        i_inst,              // Instruccio
    input  InstAddr    i_pc,                // Adressa de la instruccio
    input  RegAddr     i_EX_RegWrAddr,      // Registre per escriure
    input  logic       i_EX_RegWrEnable,    // Habilita l'escriptura en el registre
    input  logic [1:0] i_EX_RegWrDataSel,   // Seleccio de dades
    input  Data        i_EX_RegWrData,      // Dades a escriure en el registre
    input  logic       i_EX_IsLoad,         // Indica si es una instruccio Load
    input  RegAddr     i_MEM_RegWrAddr,     // Registre per escriure
    input  logic       i_MEM_RegWrEnable,   // Habilita l'escriptura
    input  Data        i_MEM_RegWrData,     // Dades a escriure
    input  logic       i_MEM_IsLoad,        // Indica si es una instauccio Load
    input  RegAddr     i_WB_RegWrAddr,      // Registre a escriure
    input  logic       i_WB_RegWrEnable,    // Autoritzacio d'escriptura del registre
    input  Data        i_WB_RegWrData,      // El resultat a escriure
    output Data        o_instIMM,           // Valor inmediat de la instruccio
    output Data        o_dataA,             // Dades A (rs1)
    output Data        o_dataB,             // Dades B (rs2)
    output logic       o_isLoad,            // Indica instruccio Load
    output logic       o_bubble,            // Indica si cal generar bombolla
    output RegAddr     o_regWrAddr,         // Registre a escriure.
    output logic       o_regWrEnable,       // Habilita l'escriptura del registre
    output logic       o_memWrEnable,       // Habilita l'escritura en memoria
    output logic [1:0] o_regWrDataSel,      // Seleccio de les dades per escriure en el registre (rd)
    output logic [1:0] o_operandASel,       // Seleccio del valor A de la ALU
    output logic [1:0] o_operandBSel,       // Seleccio del valor B de la ALU
    output AluOp       o_aluControl,        // Codi de control de la ALU
    output InstAddr    o_pcNext);           // Nou valor de PC


    // ------------------------------------------------------------------------
    // Expansor d'instruccions comprimides.
    // Converteix un instruccio comprimida al seu equivalent normal.
    // ------------------------------------------------------------------------

    Inst  exp_inst;
    logic exp_isCompressed;
    logic exp_isIllegal;

//`define RV32_COMPRESS

`ifdef RV_EXT_C
    InstExpander
    exp (
        .i_inst         (i_inst),
        .o_inst         (exp_inst),
        .o_isCompressed (exp_isCompressed),
        .o_isIllegal    (exp_isIllegal));
`else
      assign exp_inst         = i_inst;
      assign exp_isCompressed = 1'b0;
      assign exp_isIllegal    = 1'b0;
`endif


    // ------------------------------------------------------------------------
    // Decodificador d'instruccions.
    // Separa les instruccions en els seus components, calculant el valor
    // IMM de la instruccio en funcio del seu tipus. Tambe indica el tipus
    // d'instruccio.
    // ------------------------------------------------------------------------

    OpCode  dec_instOP;
    RegAddr dec_instRS1;
    RegAddr dec_instRS2;
    RegAddr dec_instRD;
    Data    dec_instIMM;
    logic   dec_isIllegal;
    logic   dec_isLoad;
    logic   dec_isALU;
    logic   dec_isECALL;
    logic   dec_isEBREAK;

    InstDecoder
    dec (
        .i_inst      (exp_inst),
        .o_instOP    (dec_instOP),
        .o_instRS1   (dec_instRS1),
        .o_instRS2   (dec_instRS2),
        .o_instRD    (dec_instRD),
        .o_instIMM   (dec_instIMM),
        .o_isIllegal (dec_isIllegal),
        .o_isLoad    (dec_isLoad),
        .o_isALU     (dec_isALU),
        .o_isECALL   (dec_isECALL),
        .o_isEBREAK  (dec_isEBREAK));


    // ------------------------------------------------------------------------
    // Controlador del datapath.
    // Genera les senyals de control de les rutes de dades.
    // ------------------------------------------------------------------------

    AluOp       dpCtrl_aluControl;   // Operacio de la ALU
    logic       dpCtrl_regWrEnable;  // Autoritza escriptura del regisres
    logic       dpCtrl_memWrEnable;  // Autoritza escritura en memoria
    logic [1:0] dpCtrl_pcNextSel;    // Selector del seguent valor del PC
    logic [1:0] dpCtrl_dataToRegSel; // Selector del les dades d'escriptura en el registre
    logic [1:0] dpCtrl_operandASel;  // Seleccio del operand A de la ALU
    logic [1:0] dpCtrl_operandBSel;  // Seleccio del operand B de la ALU

    DatapathController
    dpCtrl (
        .i_inst         (exp_inst),           // La instruccio
        .i_isEqual      (comp_equal),         // Indicador r1 == r2
        .i_isLess       (comp_less),          // Indicador r1 < r2
        .o_memWrEnable  (dpCtrl_memWrEnable),
        .o_regWrEnable  (dpCtrl_regWrEnable),
        .o_regWrDataSel (dpCtrl_dataToRegSel),
        .o_aluControl   (dpCtrl_aluControl),
        .o_operandASel  (dpCtrl_operandASel),
        .o_operandBSel  (dpCtrl_operandBSel),
        .o_pcNextSel    (dpCtrl_pcNextSel));


    // ------------------------------------------------------------------------
    // Controllador per stalling.
    // ------------------------------------------------------------------------

    StallController
    stallCtrl (
        .i_instRS1     (dec_instRS1),
        .i_instRS2     (dec_instRS2),
        .i_EX_IsLoad   (i_EX_IsLoad),
        .i_EX_RegAddr  (i_EX_RegWrAddr),
        .i_MEM_IsLoad  (i_MEM_IsLoad),
        .i_MEM_RegAddr (i_MEM_RegWrAddr),
        .o_bubble      (o_bubble));


    // ------------------------------------------------------------------------
    // Controlador de Forwarding. Selecciona el valor dels registres no
    // actualitzats, en les etapes posteriors del pipeline.
    // ------------------------------------------------------------------------

    logic [1:0] fwdCtrl_dataASel,
                fwdCtrl_dataBSel;

    ForwardController
    fwdCtrl(
        .i_instRS1         (dec_instRS1),
        .i_instRS2         (dec_instRS2),
        .i_EX_RegWrAddr    (i_EX_RegWrAddr),
        .i_EX_RegWrEnable  (i_EX_RegWrEnable),
        .i_EX_RegWrDataSel (i_EX_RegWrDataSel),
        .i_MEM_RegWrAddr   (i_MEM_RegWrAddr),
        .i_MEM_RegWrEnable (i_MEM_RegWrEnable),
        .i_WB_RegWrAddr    (i_WB_RegWrAddr),
        .i_WB_RegWrEnable  (i_WB_RegWrEnable),
        .o_dataASel        (fwdCtrl_dataASel),
        .o_dataBSel        (fwdCtrl_dataBSel));


    // -----------------------------------------------------------------------
    // Seleccio de les dades del registre o de les etapes posteriors.
    // -----------------------------------------------------------------------

    Data fwdDataASelector_output;
    Data fwdDataBSelector_output;

    Mux4To1 #(
        .WIDTH ($size(Data)))
    fwdDataASelector (
        .i_select (fwdCtrl_dataASel),
        .i_input0 (regs_dataA),
        .i_input1 (i_EX_RegWrData),
        .i_input2 (i_MEM_RegWrData),
        .i_input3 (i_WB_RegWrData),
        .o_output (fwdDataASelector_output));

    Mux4To1 #(
        .WIDTH ($size(Data)))
    fwdDataBSelector (
        .i_select (fwdCtrl_dataBSel),
        .i_input0 (regs_dataB),
        .i_input1 (i_EX_RegWrData),
        .i_input2 (i_MEM_RegWrData),
        .i_input3 (i_WB_RegWrData),
        .o_output (fwdDataBSelector_output));


    // ------------------------------------------------------------------------
    // Comparador per les instruccions de salt.
    // Permet identificas les condicions de salt abans d'executar
    // la instruccio, calculant l'adressa de salt de la seguent instruccio
    // en IF.
    // ------------------------------------------------------------------------
    //
    logic comp_equal; // Indica A == B
    logic comp_less;  // Indica A <= B

    // verilator lint_off PINMISSING
    Comparer #(
        .WIDTH ($size(Data)))
    Comp(
        .i_inputA   (fwdDataASelector_output),
        .i_inputB   (fwdDataBSelector_output),
        .i_unsigned (0),
        .o_equal    (comp_equal),
        .o_less     (comp_less));
    // verilator lint_on PINMISSING


    // ------------------------------------------------------------------------
    // Bloc de registres.
    // ------------------------------------------------------------------------

    Data regs_dataA;
    Data regs_dataB;

    RegisterFile
    regs (
        .i_clock    (i_clock),
        .i_reset    (i_reset),
        .i_wrEnable (i_WB_RegWrEnable),
        .i_wrAddr   (i_WB_RegWrAddr),
        .i_wrData   (i_WB_RegWrData),
        .i_rdAddrA  (dec_instRS1),
        .o_rdDataA  (regs_dataA),
        .i_rdAddrB  (dec_instRS2),
        .o_rdDataB  (regs_dataB));


    // ------------------------------------------------------------------------
    // Evaluacio de l'adressa de salt
    // ------------------------------------------------------------------------

    InstAddr pcAlu_pc;

    PCAlu
    pcAlu (
        .i_op      (dpCtrl_pcNextSel),
        .i_pc      (i_pc),
        .i_instIMM (dec_instIMM),
        .i_regData (regs_dataA),
        .o_pc      (pcAlu_pc));


    always_comb begin
        o_instIMM      = dec_instIMM;
        o_dataA        = fwdDataASelector_output;
        o_dataB        = fwdDataBSelector_output;
        o_isLoad       = dec_isLoad;
        o_regWrAddr    = dec_instRD;
        o_regWrEnable  = dpCtrl_regWrEnable;
        o_regWrDataSel = dpCtrl_dataToRegSel;
        o_memWrEnable  = dpCtrl_memWrEnable;
        o_operandASel  = dpCtrl_operandASel;
        o_operandBSel  = dpCtrl_operandBSel;
        o_aluControl   = dpCtrl_aluControl;
        o_pcNext       = pcAlu_pc;
    end


endmodule
