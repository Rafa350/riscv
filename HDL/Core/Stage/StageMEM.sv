module StageMEM
    import Types::*;
(
    // Senyals de control
    input  logic      i_clock,        // Clock
    input  logic      i_reset,        // Reset

    // Interficie amb la memoria de dades
    DataBus.master    dataBus,        // Bus de la memoria de dades

    // Senyals operatives del stage
    input  logic      i_isValid,      // Indica operacio valida
    input  InstAddr   i_pc,           // Adressa de la instruccio
    input  Data       i_dataR,        // Dades del resultst
    input  Data       i_dataB,        // Dades per escriure

    input  logic      i_memWrEnable,  // Habilita escriptura en memoria
    input  logic      i_memRdEnable,  // Habilita la lectura de la memoria
    input  DataAccess i_memAccess,    // Tamany d'acces a la memori
    input  logic      i_memUnsigned,  // Lectura de memoria sense signe

    input  logic [1:0] i_regWrDataSel, // Seleccio de dades per escriure en el registre
    output logic       o_hazard,       // Indica hazard
    output Data        o_regWrData);   // Dades per escriure en el registre


    assign o_hazard = 1'b0;


    // ------------------------------------------------------------------------
    // Interface amb la memoria de dades.
    // ------------------------------------------------------------------------

    Data  memAdapter_rdData;
    logic memAdapter_alignError;
    logic memAdapter_busy;

    DataMemoryAdapter
    memAdapter (
        .i_clock      (i_clock),
        .i_reset      (i_reset),
        .i_addr       (i_dataR[$size(DataAddr)-1:0]),
        .i_unsigned   (i_memUnsigned),
        .i_access     (i_memAccess),
        .i_wrEnable   (i_memWrEnable & i_isValid),
        .i_rdEnable   (i_memRdEnable & i_isValid),
        .i_wrData     (i_dataB),
        .o_rdData     (memAdapter_rdData),
        .o_busy       (memAdapter_busy),
        .o_alignError (memAdapter_alignError),
        .bus          (dataBus));


    /// -----------------------------------------------------------------------
    /// Evalua PC + 4
    /// -----------------------------------------------------------------------

    InstAddr adder_output;

    HalfAdder #(
        .WIDTH ($size(InstAddr)))
    adder (
        .i_inputA (i_pc),
        .i_inputB (InstAddr'(4)),
        .o_output (adder_output));


    // ------------------------------------------------------------------------
    // Selecciona les dades per escriure en el registre de destinacio en
    // funcio de la senyal i_RegWrDataSel
    //
    //     2'b00: El valor R
    //     2'b01: El valor lleigit de la memoria de dades
    //     2'b10: El valor de PC + 4
    //
    // ------------------------------------------------------------------------

    // verilator lint_off PINMISSING
    Mux4To1 #(
        .WIDTH ($size(Data)))
    regWrDataSelector (
        .i_select (i_regWrDataSel),
        .i_input0 (i_dataR),
        .i_input1 (memAdapter_rdData),
        .i_input2 ({{$size(Data)-$size(InstAddr){1'b0}}, adder_output}),
        .o_output (o_regWrData));
    // verilator lint_on PINMISSING


endmodule
