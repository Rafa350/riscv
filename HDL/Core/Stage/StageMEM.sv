`include "RV.svh"


module StageMEM
    import Types::*;
(
    DataMemoryBus.master dataBus,        // Bus de la memoria de dades

    input  InstAddr      i_pc,           // Adressa de la instruccio
    input  Data          i_result,       // Adressa de memoria
    input  Data          i_dataB,        // Dades per escriure

    input  logic         i_memWrEnable,  // Habilita escriptura en memoria
    input  DataAccess    i_memAccess,    // Tamany d'acces a la memori
    input  logic         i_memUnsigned,  // Lectura de memoria sense signe

    input  logic [1:0]   i_regWrDataSel, // Seleccio de dades per escriure en el registre
    output Data          o_regWrData);   // Dades per escriure en el registre


    // ------------------------------------------------------------------------
    // Interface amb la memoria de dades.
    // ------------------------------------------------------------------------

    assign dataBus.addr     = i_result[$size(DataAddr)-1:0];
    assign dataBus.access   = i_memAccess;
    assign dataBus.wrEnable = i_memWrEnable;
    assign dataBus.wrData   = i_dataB;

    Data rdData;
    always_comb begin
        unique case ({i_memUnsigned, i_memAccess})
            // Signed byte
            {1'b0, DataAccess_Byte}:
                 rdData = {dataBus.rdData[7] ? 25'h1FFFFFF : 25'h0, dataBus.rdData[6:0]};

            // Signed half
            {1'b0, DataAccess_Half}:
                rdData = {dataBus.rdData[15] ? 17'h1FFFF : 17'h0, dataBus.rdData[14:0]};

            // Unsigned byte
            {1'b1, DataAccess_Byte}:
                rdData = {24'h000000, dataBus.rdData[7:0]};

            // Unsigned half
            {1'b1, DataAccess_Half}:
                rdData = {16'h0000, dataBus.rdData[15:0]};

            // Word
            default:
                rdData = dataBus.rdData;
        endcase
    end


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
        .i_input1 (rdData),
        .i_input2 ({{$size(Data)-$size(InstAddr){1'b0}}, adder_result}),
        .o_output (o_regWrData));
    // verilator lint_on PINMISSING

endmodule
