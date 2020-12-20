`include "RV.svh"


module StageMEM
    import Types::*;
(
    DataMemoryBus.master dataBus,        // Bus de la memoria de dades

    input  InstAddr      i_pc,
    input  Data          i_result,
    input  Data          i_dataB,

    input  logic         i_memWrEnable,  // Habilita escriptura en memoria

    input  logic [1:0]   i_regWrDataSel, // Seleccio de dades per escriure en el registre
    output Data          o_regWrData);   // Dades per escriure en el registre


    // ------------------------------------------------------------------------
    // Interface amb la memoria de dades.
    // ------------------------------------------------------------------------

    assign dataBus.addr     = i_result[$size(DataAddr)-1:0];
    assign dataBus.wrData   = i_dataB;
    assign dataBus.wrEnable = i_memWrEnable;

    Data memDataSel_output;

    // verilator lint_off PINMISSING
    Mux8To1 #(
        .WIDTH ($size(Data)))
    memDataSel (
        .i_select(2),
        .i_input0 ({dataBus.rdData[7] ? 24'hFFFFFF : 24'h000000, dataBus.rdData[7:0]}), // Acces signed byte
        .i_input1 ({dataBus.rdData[15] ? 16'hFFFF : 16'h0000, dataBus.rdData[15:0]}),   // Acces signed half
        .i_input2 (dataBus.rdData),                                                     // Acces word
        .i_input3 ({24'h000000, dataBus.rdData[7:0]}),                                  // Acces unsigned byte
        .i_input4 ({16'h0000, dataBus.rdData[15:0]}),                                   // Acces unsigned half
        .o_output (memDataSel_output));
    // verilator lint_on PINMISSING


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
        .i_input1 (memDataSel_output),
        .i_input2 ({{$size(Data)-$size(InstAddr){1'b0}}, adder_result}),
        .o_output (o_regWrData));
    // verilator lint_on PINMISSING

endmodule
