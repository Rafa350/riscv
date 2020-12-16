module StageMEM
#(
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 32,
    parameter PC_WIDTH   = 32,
    parameter REG_WIDTH  = 5)
(
    DataMemoryBus.Master          DBus,           // Bus de la memoria de dades

    input  logic [PC_WIDTH-1:0]   i_PC,
    input  logic [DATA_WIDTH-1:0] i_Result,
    input  logic [DATA_WIDTH-1:0] i_DataB,

    input  logic                  i_MemWrEnable,  // Habilita escriptura en memoria

    input  logic [1:0]            i_RegWrDataSel, // Seleccio de dades per escriure en el registre
    output logic [DATA_WIDTH-1:0] o_RegWrData);   // Dades per escriure en el registre


    // ------------------------------------------------------------------------
    // Interface amb la memoria de dades.
    // ------------------------------------------------------------------------

    assign DBus.Addr     = i_Result[ADDR_WIDTH-1:0];
    assign DBus.WrData   = i_DataB;
    assign DBus.WrEnable = i_MemWrEnable;


    /// -----------------------------------------------------------------------
    /// Evalua PC + 4
    /// -----------------------------------------------------------------------

    logic [PC_WIDTH-1:0] Adder_Result;

    HalfAdder #(
        .WIDTH (PC_WIDTH))
    Adder (
        .i_OperandA (i_PC),
        .i_OperandB (4),
        .o_Result   (Adder_Result));


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
        .WIDTH (DATA_WIDTH))
    RegWrDataSelector (
        .i_Select (i_RegWrDataSel),
        .i_Input0 (i_Result),
        .i_Input1 (DBus.RdData),
        .i_Input2 ({{DATA_WIDTH-PC_WIDTH{1'b0}}, Adder_Result}),
        .o_Output (o_RegWrData));
    // verilator lint_on PINMISSING

endmodule
