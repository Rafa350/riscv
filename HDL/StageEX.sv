// verilator lint_off IMPORTSTAR
import types::*;


module StageEX
#(
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 32,
    parameter PC_WIDTH   = 32,
    parameter REG_WIDTH  = 5) 
(
    input  logic                  i_Clock,
    input  logic                  i_Reset,

    input  logic [DATA_WIDTH-1:0] i_DataA,
    input  logic [DATA_WIDTH-1:0] i_DataB,
    input  logic [PC_WIDTH-1:0]   i_PC,         // Adressa de la instruccio
    input  AluOp                  i_AluControl,

    output logic [DATA_WIDTH-1:0] o_Result);


    // -------------------------------------------------------------------
    // Realitzacio dels calculs en la ALU
    // -------------------------------------------------------------------

    Alu #(
        .WIDTH (DATA_WIDTH))
    Alu (
        .i_Op       (i_AluControl),
        .i_OperandA (i_DataA),
        .i_OperandB (i_DataB),
        .o_Result   (o_Result));

endmodule
