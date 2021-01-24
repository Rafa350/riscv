// -----------------------------------------------------------------------
//
//       Multiplexor de 8 a 1
//
//       Parametres:
//            WIDTH     : Amplada del canal de dades en bits
//
//       Entrades:
//            i_select  : Seleccio del canal d'entrada
//            i_input0  : Canal d'entrada 0
//            i_input1  : Canal d'entrada 1
//            i_input2  : Canal d'entrada 2
//            i_input3  : Canal d'entrada 3
//            i_input4  : Canal d'entrada 4
//            i_input5  : Canal d'entrada 5
//            i_input6  : Canal d'entrada 6
//            i_input7  : Canal d'entrada 7
//
//       Sortides:
//            o_output  : El valor del canal seleccionat.
//
// -----------------------------------------------------------------------

module Mux8To1
#(
    parameter WIDTH = 32)
(
    input  logic [2:0]       i_select,

    input  logic [WIDTH-1:0] i_input0,
    input  logic [WIDTH-1:0] i_input1,
    input  logic [WIDTH-1:0] i_input2,
    input  logic [WIDTH-1:0] i_input3,
    input  logic [WIDTH-1:0] i_input4,
    input  logic [WIDTH-1:0] i_input5,
    input  logic [WIDTH-1:0] i_input6,
    input  logic [WIDTH-1:0] i_input7,

    output logic [WIDTH-1:0] o_output);

    always_comb
        case (i_select)
            3'b000: o_output = i_input0;
            3'b001: o_output = i_input1;
            3'b010: o_output = i_input2;
            3'b011: o_output = i_input3;
            3'b100: o_output = i_input4;
            3'b101: o_output = i_input5;
            3'b110: o_output = i_input6;
            3'b111: o_output = i_input7;
        endcase

endmodule