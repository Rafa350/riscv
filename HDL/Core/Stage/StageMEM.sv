`include "RV.svh"


module StageMEM
    import Types::*;
(
    // Senyals de control
    input  logic         i_clock,        // Clock
    input  logic         i_reset,        // Reset

    // Interficie amb la memoria de dades
    DataMemoryBus.master dataBus,        // Bus de la memoria de dades

    // Datapath
    input  InstAddr      i_pc,           // Adressa de la instruccio
    input  Data          i_result,       // Adressa de memoria
    input  Data          i_dataB,        // Dades per escriure

    input  logic         i_memWrEnable,  // Habilita escriptura en memoria
    input  logic         i_memRdEnable,  // Habilita la lectura de la memoria
    input  DataAccess    i_memAccess,    // Tamany d'acces a la memori
    input  logic         i_memUnsigned,  // Lectura de memoria sense signe

    input  logic [1:0]   i_regWrDataSel, // Seleccio de dades per escriure en el registre
    output Data          o_regWrData);   // Dades per escriure en el registre


    // ------------------------------------------------------------------------
    // Interface amb la memoria de dades.
    // ------------------------------------------------------------------------

    Data  memAdapter_rdData;
    logic memAdapter_alignError;

    DataMemoryAdapter
    memAdapter (
        .i_clock      (i_clock),
        .i_reset      (i_reset),
        .i_addr       (i_result[$size(DataAddr)-1:0]),
        .i_unsigned   (i_memUnsigned),
        .i_access     (i_memAccess),
        .i_wrEnable   (i_memWrEnable),
        .i_rdEnable   (i_memRdEnable),
        .i_wrData     (i_dataB),
        .o_rdData     (memAdapter_rdData),
        .bus          (dataBus),
        .o_alignError (memAdapter_alignError));


    /// -----------------------------------------------------------------------
    /// Evalua PC + 4
    /// -----------------------------------------------------------------------

    InstAddr adder_result;

    HalfAdder #(
        .WIDTH ($size(InstAddr)))
    adder (
        .i_operandA (i_pc),
        .i_operandB (4),
        .o_result   (adder_result));


    // ------------------------------------------------------------------------
    // Selecciona les dades per escriure en el registre de destinacio en
    // funcio de la senyal i_RegWrDataSel
    //
    //     2'b00: El resultat de la ALU
    //     2'b01: El valor lleigit de la memoria de dades
    //     2'b10: El valor de PC + 4
    //
    // ------------------------------------------------------------------------

    // verilator lint_off PINMISSING
    Mux4To1 #(
        .WIDTH ($size(Data)))
    regWrDataSelector (
        .i_select (i_regWrDataSel),
        .i_input0 (i_result),
        .i_input1 (memAdapter_rdData),
        .i_input2 ({{$size(Data)-$size(InstAddr){1'b0}}, adder_result}),
        .o_output (o_regWrData));
    // verilator lint_on PINMISSING

endmodule
