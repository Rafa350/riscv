module StageIF
#(
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 32,
    parameter PC_WIDTH   = 32,
    parameter REG_WIDTH  = 5)
(
    input  logic                i_Clock,   // Clock
    input  logic                i_Reset,   // Reset

    InstMemoryBus.Master        IBus,      // Bus de la memoria d'instruccions

    input  logic [PC_WIDTH-1:0] i_PCNext,  // El nou PC
    output logic [31:0]         o_Inst,    // Instruccio
    output logic [PC_WIDTH-1:0] o_PC);     // PC


    // ------------------------------------------------------------------------
    // Control del PC
    // ------------------------------------------------------------------------

    assign o_PC      = i_PCNext;
    assign o_Inst    = IBus.Inst;
    assign IBus.Addr = o_PC;

    // Mirar d'expandir la instruccio comprimida aqui

endmodule
