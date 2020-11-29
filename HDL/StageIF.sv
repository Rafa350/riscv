module StageIF
#(
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 32,
    parameter PC_WIDTH   = 32,
    parameter REG_WIDTH  = 5)
(
    input  logic                i_Clock,   // Clock
    input  logic                i_Reset,   // Reset

    input  logic [31:0]         i_PgmInst, // Instruccio de programa
    output logic [PC_WIDTH-1:0] o_PgmAddr, // Adressa de programa

    input  logic [PC_WIDTH-1:0] i_PCNext,  // El nou PC
    output logic [31:0]         o_Inst,    // Instruccio
    output logic [PC_WIDTH-1:0] o_PC);     // PC


    // ------------------------------------------------------------------------
    // Control del PC
    // ------------------------------------------------------------------------

    assign o_PC      = i_PCNext;
    assign o_PgmAddr = o_PC;
    assign o_Inst    = i_PgmInst;


endmodule
