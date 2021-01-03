`include "RV.svh"

module ProcessorSC
    import Types::*;
(
    input  logic         i_clock, // Clock
    input  logic         i_reset, // Reset

    DataMemoryBus.master dataBus,    // Bus de dades
    InstMemoryBus.master instBus);   // Bus d'instruccions


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
        .i_ok           (1),
        .i_tick         (dbgCtrl_tick),
        .i_pc           (instBus.addr),
        .i_inst         (instBus.inst),
        .i_regWrAddr    (dec_instRD),
        .i_regWrData    (sel3_output),
        .i_regWrEnable  (dpCtrl_regWrEnable),
        .i_memWrAddr    (dataBus.addr),
        .i_memWrData    (dataBus.wrData),
        .i_memWrEnable  (dpCtrl_memWrEnable),
        .o_tick         (dbgCtrl_tick));


    // ------------------------------------------------------------------------
    // Control del datapath. Genera les senyals de control
    // ------------------------------------------------------------------------

    AluOp       dpCtrl_aluControl;   // Operacio de la ALU
    logic       dpCtrl_regWrEnable;  // Autoritza escriptura del regisres
    logic       dpCtrl_memWrEnable;  // Autoritza escritura en memoria
    logic       dpCtrl_memRdEnable;
    DataAccess  dpCtrl_memAccess;    // Tipus d'acces a la memoria (byte, half o word)
    logic       dpCtrl_memUnsigned;
    logic [1:0] dpCtrl_pcNextSel;    // Selector del seguent valor del PC
    logic [1:0] dpCtrl_regWrDataSel; // Selector del les dades d'esacriptura en el registre
    logic [1:0] dpCtrl_operandASel;  // Seleccio del operand A de la ALU
    logic [1:0] dpCtrl_operandBSel;  // Seleccio del operand B de la ALU

    DatapathController
    dpCtrl (
        .i_inst         (instBus.inst),
        .i_isEqual      (comp_equal),
        .i_isLess       (comp_less),
        .o_aluControl   (dpCtrl_aluControl),
        .o_memWrEnable  (dpCtrl_memWrEnable),
        .o_memRdEnable  (dpCtrl_memRdEnable),
        .o_memAccess    (dpCtrl_memAccess),
        .o_memUnsigned  (dpCtrl_memUnsigned),
        .o_regWrEnable  (dpCtrl_regWrEnable),
        .o_operandASel  (dpCtrl_operandASel),
        .o_operandBSel  (dpCtrl_operandBSel),
        .o_regWrDataSel (dpCtrl_regWrDataSel),
        .o_pcNextSel    (dpCtrl_pcNextSel));


    // ------------------------------------------------------------------------
    // Decodificador d'instruccions. Extreu els parametres de la instruccio
    // ------------------------------------------------------------------------

    Data    dec_instIMM;
    RegAddr dec_instRS1;
    RegAddr dec_instRS2;
    RegAddr dec_instRD;

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

    logic comp_equal; // Indica A == B
    logic comp_less;  // Indica A <= B

    // verilator lint_off PINMISSING
    Comparer #(
        .WIDTH (DATA_WIDTH))
    comp (
        .i_inputA   (regs_rdDataA),
        .i_inputB   (regs_rdDataB),
        .i_unsigned (0),
        .o_equal    (comp_equal),
        .o_less     (comp_less));
    // verilator lint_on PINMISSING


    // ------------------------------------------------------------------------
    // Bloc de registres
    // ------------------------------------------------------------------------

    Data regs_rdDataA, // Dades de lectura A
         regs_rdDataB; // Dades de lectura B

    RegisterFile
    regs (
        .i_clock    (i_clock),
        .i_reset    (i_reset),
        .i_wrAddr   (dec_instRD),
        .i_wrData   (sel3_output),
        .i_wrEnable (dpCtrl_regWrEnable),
        .i_rdAddrA  (dec_instRS1),
        .o_rdDataA  (regs_rdDataA),
        .i_rdAddrB  (dec_instRS2),
        .o_rdDataB  (regs_rdDataB));


    // ------------------------------------------------------------------------
    // Selecciona les dades d'entrada A de la alu
    // ------------------------------------------------------------------------

    logic [DATA_WIDTH-1:0] sel5_output;

    // verilator lint_off PINMISSING
    Mux4To1 #(
        .WIDTH (DATA_WIDTH))
    sel5 (
        .i_select (dpCtrl_operandASel),
        .i_input0 (regs_rdDataA),
        .i_input1 ({{DATA_WIDTH-PC_WIDTH{1'b0}}, pc}),
        .i_input2 ('d0),
        .o_output (sel5_output));
    // verilator lint_on PINMISSING


    // ------------------------------------------------------------------------
    // Selecciona les dades d'entrada B de la ALU
    // ------------------------------------------------------------------------

    logic [DATA_WIDTH-1:0] sel1_output;

    // verilator lint_off PINMISSING
    Mux4To1 #(
        .WIDTH (DATA_WIDTH))
    sel1 (
        .i_select (dpCtrl_operandBSel),
        .i_input0 (regs_rdDataB),
        .i_input1 (dec_instIMM),
        .i_input2 ('d4),
        .o_output (sel1_output));
    // verilator lint_on PINMISSING


    // ------------------------------------------------------------------------
    // Selecciona les dades per escriure en el registre
    // ------------------------------------------------------------------------

    logic [DATA_WIDTH-1:0] sel3_output;

    // verilator lint_off PINMISSING
    Mux4To1 #(
        .WIDTH  (DATA_WIDTH))
    sel3 (
        .i_select (dpCtrl_regWrDataSel),
        .i_input0 (alu_result),             // Escriu el resultat de la ALU
        .i_input1 (dataBus.rdData),            // Escriu el valor lleigit de la memoria
        .i_input2 ({{DATA_WIDTH-PC_WIDTH{1'b0}}, pcPlus4}), // Escriu el valor de PC+4
        .o_output (sel3_output));
    // verilator lint_on PINMISSING


    // ------------------------------------------------------------------------
    // ALU
    // ------------------------------------------------------------------------

    logic [DATA_WIDTH-1:0] alu_result;

    ALU #(
        .WIDTH (DATA_WIDTH))
    alu (
        .i_op       (dpCtrl_aluControl),
        .i_operandA (sel5_output),
        .i_operandB (sel1_output),
        .o_result   (alu_result));


    // Evalua PC = PC + 4
    //
    HalfAdder #(
        .WIDTH (PC_WIDTH))
    adder1 (
        .i_operandA (pc),
        .i_operandB (4),
        .o_result   (pcPlus4));


    // Evalua PC = PC + offset
    //
    InstAddr pcPlusOffset;

    HalfAdder #(
        .WIDTH (PC_WIDTH))
    Adder2 (
        .i_operandA (pc),
        .i_operandB (dec_instIMM[PC_WIDTH-1:0]),
        .o_result   (pcPlusOffset));


    // Evalua PC = [rs1] + offset
    //
    logic [PC_WIDTH-1:0] pcPlusOffsetAndRS1;

    HalfAdder #(
        .WIDTH (PC_WIDTH))
    adder3 (
        .i_operandA (dec_instIMM[PC_WIDTH-1:0]),
        .i_operandB (regs_rdDataA[PC_WIDTH-1:0]),
        .o_result   (pcPlusOffsetAndRS1));


    // Selecciona el nou valor del contador de programa
    //
    Mux4To1 #(
        .WIDTH ($size(InstAddr)))
    sel4 (
        .i_select (dpCtrl_pcNextSel),
        .i_input0 (pcPlus4),
        .i_input1 (pcPlusOffset),
        .i_input2 (pcPlusOffsetAndRS1),
        .i_input3 (pcPlus4),
        .o_output (pcNext));

    // Registre del contador de programa
    //
    Register #(
        .WIDTH ($size(InstAddr)),
        .INIT  ({PC_WIDTH{1'b0}}))
    PCReg (
        .i_clock    (i_clock),
        .i_reset    (i_reset),
        .i_wrEnable (1),
        .i_wrData   (pcNext),
        .o_rdData   (pc));


    // Interface amb la memoria RAM
    //
    always_comb begin
        dataBus.addr     = alu_result[$size(DataAddr)-1:0];
        dataBus.wrEnable = dpCtrl_memWrEnable;
        dataBus.wrData   = regs_rdDataB;
    end


    // Interface amb la memoria de programa
    //
    assign instBus.addr = pc;

endmodule
