module CoreSC
    import Config::*, CoreDefs::*;
(
    input  logic   i_clock,  // Clock
    input  logic   i_reset,  // Reset
    DataBus.master dataBus,  // Bus de dades
    InstBus.master instBus); // Bus d'instruccions


    // ------------------------------------------------------------------------
    // Program counter (PC)
    // ------------------------------------------------------------------------

    InstAddr pc;       // Valor actual del PC
    InstAddr pcNext;   // Valor per actualitzar PC
    InstAddr pcPlus4;  // Valor incrementat (+4)


    // ------------------------------------------------------------------------
    // Depuracio
    // ------------------------------------------------------------------------

    int dbgCtrl_tick;

    DebugController
    dbgCtrl (
        .i_clock        (i_clock),
        .i_reset        (i_reset),
        .i_stall        (0),
        .i_isValid      (1),
        .i_tick         (dbgCtrl_tick),
        .i_pc           (instBus.addr),
        .i_inst         (instBus.inst),
        .i_regWrAddr    (dec_instRD),
        .i_regWrData    (wrDataSelector_output),
        .i_regWrEnable  (dpCtrl_regWrEnable),
        .i_memWrAddr    (dataBus.addr),
        .i_memAccess    (dpCtrl_memAccess),
        .i_memWrData    (dataBus.wdata),
        .i_memWrEnable  (dpCtrl_memWrEnable),
        .o_tick         (dbgCtrl_tick));


    // ------------------------------------------------------------------------
    // Control del datapath. Genera les senyals de control
    // ------------------------------------------------------------------------

    AluOp       dpCtrl_aluControl;   // Operacio de la unitat ALU
    MduOp       dpCtrl_mduControl;   // Operacio de la unitat MDU
    CsrOp       dpCtrl_csrControl;   // Operacio en la unitat CSR
    logic       dpCtrl_regWrEnable;  // Autoritza escriptura del regisres
    logic       dpCtrl_memWrEnable;  // Autoritza escritura en memoria
    logic       dpCtrl_memRdEnable;
    DataAccess  dpCtrl_memAccess;    // Tipus d'acces a la memoria (byte, half o word)
    logic       dpCtrl_memUnsigned;
    logic [1:0] dpCtrl_pcNextSel;    // Selector del seguent valor del PC
    WrDataSel   dpCtrl_regWrDataSel; // Selector del les dades d'esacriptura en el registre
    DataASel    dpCtrl_operandASel;  // Seleccio del operand A
    DataBSel    dpCtrl_operandBSel;  // Seleccio del operand B
    ResultSel   dpCtrl_resultSel;    // Seleccio del resultat

    DatapathController
    dpCtrl (
        .i_inst           (instBus.inst),
        .i_isEqual        (brComp_isEqual),
        .i_isLessSigned   (brComp_isLessSigned),
        .i_isLessUnsigned (brComp_isLessUnsigned),
        .o_aluControl     (dpCtrl_aluControl),
        .o_mduControl     (dpCtrl_mduControl),
        .o_csrControl     (dpCtrl_csrControl),
        .o_memWrEnable    (dpCtrl_memWrEnable),
        .o_memRdEnable    (dpCtrl_memRdEnable),
        .o_memAccess      (dpCtrl_memAccess),
        .o_memUnsigned    (dpCtrl_memUnsigned),
        .o_regWrEnable    (dpCtrl_regWrEnable),
        .o_operandASel    (dpCtrl_operandASel),
        .o_operandBSel    (dpCtrl_operandBSel),
        .o_resultSel      (dpCtrl_resultSel),
        .o_regWrDataSel   (dpCtrl_regWrDataSel),
        .o_pcNextSel      (dpCtrl_pcNextSel));


    // ------------------------------------------------------------------------
    // Decodificador d'instruccions. Extreu els parametres de la instruccio
    // ------------------------------------------------------------------------

    Data    dec_instIMM;
    GPRAddr dec_instRS1;
    GPRAddr dec_instRS2;
    GPRAddr dec_instRD;

    // verilator lint_off PINMISSING
    InstDecoder
    dec (
        .i_inst   (instBus.inst),
        .o_instRS1 (dec_instRS1),
        .o_instRS2 (dec_instRS2),
        .o_instRD  (dec_instRD),
        .o_instIMM (dec_instIMM));
    // verilator lint_on PINMISSING


    // ------------------------------------------------------------------------
    // Compara els valors del registre per decidir els salta condicionals
    // ------------------------------------------------------------------------

    logic brComp_isEqual;        // Indica A == B
    logic brComp_isLessSigned;   // Indica A < B amb signe
    logic brComp_isLessUnsigned; // Indica A < B sense signe

    BranchComparer
    brComp (
        .i_dataRS1        (gpr_rdataA),
        .i_dataRS2        (gpr_rdataB),
        .o_isEqual        (brComp_isEqual),
        .o_isLessSigned   (brComp_isLessSigned),
        .o_isLessUnsigned (brComp_isLessUnsigned));


    // ------------------------------------------------------------------------
    // Bloc de registres
    // ------------------------------------------------------------------------

    Data gpr_rdataA, // Dades de lectura A
         gpr_rdataB; // Dades de lectura B

    GPRegisters
    gpr (
        .i_clock  (i_clock),
        .i_reset  (i_reset),
        .i_raddrA (dec_instRS1),
        .i_raddrB (dec_instRS2),
        .i_waddr  (dec_instRD),
        .i_we     (dpCtrl_regWrEnable),
        .o_rdataA (gpr_rdataA),
        .o_rdataB (gpr_rdataB),
        .i_wdata  (wrDataSelector_output));


    // ------------------------------------------------------------------------
    // Selecciona les dades d'entrada A de la alu
    // ------------------------------------------------------------------------

    Data operandASelector_output;

    Mux4To1 #(
        .WIDTH ($size(Data)))
    operandASelector (
        .i_select (dpCtrl_operandASel),
        .i_input0 (gpr_rdataA),
        .i_input1 (dec_instIMM),
        .i_input2 (Data'(0)),
        .i_input3 (Data'(pc)),
        .o_output (operandASelector_output));


    // ------------------------------------------------------------------------
    // Selecciona les dades d'entrada B de la ALU
    // ------------------------------------------------------------------------

    Data operandBSelector_output;

    // verilator lint_off PINMISSING
    Mux4To1 #(
        .WIDTH ($size(Data)))
    operandBSelector (
        .i_select (dpCtrl_operandBSel),
        .i_input0 (gpr_rdataB),
        .i_input1 (dec_instIMM),
        .i_input2 (Data'(4)),
        .o_output (operandBSelector_output));
    // verilator lint_on PINMISSING


    // ------------------------------------------------------------------------
    // Selecciona les dades per escriure en el registre
    // ------------------------------------------------------------------------

    Data wrDataSelector_output;

    // verilator lint_off PINMISSING
    Mux2To1 #(
        .WIDTH ($size(Data)))
    wrDataSelector (
        .i_select (dpCtrl_regWrDataSel),
        .i_input0 (alu_result),             // Escriu el resultat de la ALU
        .i_input1 (dataBus.rdata),          // Escriu el valor lleigit de la memoria
        .o_output (wrDataSelector_output));
    // verilator lint_on PINMISSING


    // -------------------------------------------------------------------
    // ALU
    // -------------------------------------------------------------------

    Data alu_result;

    ALU
    alu (
        .i_op     (dpCtrl_aluControl),
        .i_dataA  (operandASelector_output),
        .i_dataB  (operandBSelector_output),
        .o_result (alu_result));


    // -------------------------------------------------------------------
    // ALU de salts
    // -------------------------------------------------------------------

    BranchAlu
    branchAlu (
        .i_op      (dpCtrl_pcNextSel),
        .i_pc      (pc),
        .i_instIMM (dec_instIMM[$size(InstAddr)-1:0]),
        .i_regData (gpr_rdataA[$size(InstAddr)-1:0]),
        .o_pc      (pcNext));


    // Registre del contador de programa
    //
    Register #(
        .WIDTH ($size(InstAddr)),
        .INIT  (InstAddr'(0)))
    PCReg (
        .i_clock (i_clock),
        .i_reset (i_reset),
        .i_we    (1),
        .i_wdata (pcNext),
        .o_rdata (pc));


    // Interface amb la memoria RAM
    //
    always_comb begin
        dataBus.addr  = alu_result[$size(DataAddr)-1:0];
        dataBus.we    = dpCtrl_memWrEnable;
        dataBus.wdata = gpr_rdataB;
    end


    // Interface amb la memoria de programa
    //
    assign instBus.addr = pc;

endmodule
