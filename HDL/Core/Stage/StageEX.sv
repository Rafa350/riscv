module StageEX
    import Types::*;
(
    // Senyals de control
    input  logic     i_clock,       // Senyal clock
    input  logic     i_reset,       // Senyal reset

    // Senyals operatives del stage
    input  logic     i_isValid,     // Indica opewracio valida
    input  Data      i_instIMM,     // Valor IMM de la instruccio
    input  CSRAddr   i_instCSR,     // Valor CSR de la instruccio
    input  Data      i_dataRS1,     // Valor del registre X[RS1]
    input  Data      i_dataRS2,     // Valor del registre X[RS2]
    input  InstAddr  i_pc,          // Adressa de la instruccio
    input  DataASel  i_operandASel, // Seleccio del operand A
    input  DataBSel  i_operandBSel, // Seleccio del operand B
    input  ResultSel i_resultSel,   // Seleccio del resultat
    input  AluOp     i_aluControl,  // Operacio en la unitat ALU
    input  CsrOp     i_csrControl,  // Operacio en la unitat CSR
    input  logic     i_evInstRet,   // Indicador instruccio retirada
    input  logic     i_evMemRead,   // Indica memoria lleigida
    input  logic     i_evMemWrite,  // Indica memoria escrita
    output logic     o_hazard,      // Indica hazard
    output Data      o_dataR,       // Dades del resultat
    output Data      o_dataB);      // Dades B


    // -----------------------------------------------------------------------
    // Selector del operand A
    // -----------------------------------------------------------------------

    Data operandASelector_output;

    Mux4To1 #(
        .WIDTH ($size(Data)))
    operandASelector (
        .i_select (i_operandASel),
        .i_input0 (i_dataRS1),                // Valor del registre RS1
        .i_input1 (i_instIMM),                // Valor inmediat
        .i_input2 (Data'(0)),                 // Valor 0
        .i_input3 (Data'(i_pc)),              // Valor de PC
        .o_output (operandASelector_output));


    // -----------------------------------------------------------------------
    // Selector del operand B
    // -----------------------------------------------------------------------

    Data operandBSelector_output;

    // verilator lint_off PINMISSING
    Mux4To1 #(
        .WIDTH ($size(Data)))
    operandBSelector (
        .i_select (i_operandBSel),
        .i_input0 (i_dataRS2),                // Valor del registre RS2
        .i_input1 (i_instIMM),                // Valor inmediat
        .i_input2 (Data'(4)),                 // Valor 4
        .o_output (operandBSelector_output));
    // verilator lint_on PINMISSING


    // -------------------------------------------------------------------
    // Unitat d'execucio CSR (Registres d'estat i control)
    // -------------------------------------------------------------------

    Data csrUnit_data;

    CSRUnit
    csrUnit (
        .i_clock       (i_clock),
        .i_reset       (i_reset),
        .i_evInstRet   (i_evInstRet),
        .i_evICacheMis (0),
        .i_evICacheHit (0),
        .i_evDCacheMis (0),
        .i_evDCacheHit (0),
        .i_evMemRead   (i_evMemRead),
        .i_evMemWrite  (i_evMemWrite),
        .i_op          (i_isValid ? i_csrControl : CsrOp_NOP),
        .i_csr         (i_instCSR),
        .i_data        (operandASelector_output),
        .o_data        (csrUnit_data));


    // ------------------------------------------------------------------
    // Unitat d'execucio MUL (Multiplicacio i divisio)
    // ------------------------------------------------------------------


    // -------------------------------------------------------------------
    // Unitat d'execucio ALU (Calculs aritmetics i logics amb enters)
    // -------------------------------------------------------------------

    Data aluUnit_result;

    ALU
    aluUnit (
        .i_op     (i_aluControl),
        .i_dataA  (operandASelector_output),
        .i_dataB  (operandBSelector_output),
        .o_result (aluUnit_result));


    // ------------------------------------------------------------------
    // Seleccio del resultat
    // ------------------------------------------------------------------

    Data resultSelector_output;

    // verilator lint_off PINMISSING
    Mux4To1 #(
        .WIDTH ($size(Data)))
    resultSelector (
        .i_select (i_resultSel),
        .i_input0 (aluUnit_result),
        .i_input1 (csrUnit_data),
        .o_output (resultSelector_output));
    // verilator lint_on PINMISSING


    // -------------------------------------------------------------------
    // Asignacio de sortides
    // -------------------------------------------------------------------

    assign o_hazard = 1'b0;
    assign o_dataR  = resultSelector_output;
    assign o_dataB  = i_dataRS2;

endmodule
