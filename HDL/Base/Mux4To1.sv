// -----------------------------------------------------------------------
//
//       Multiplexor de 4 a 1
//
//       Parametres:
//            WIDTH     : Amplada del canal de dades
//
//       Entrades:
//            i_select  : Seleccio del canal d'entrada
//            i_input0  : Canal d'entrada 0
//            i_input1  : Canal d'entrada 1
//            i_input2  : Canal d'entrada 2
//            i_input3  : Canal d'entrada 3
//
//       Sortides:
//            o_output  : El valor de l'entrada seleccionada.
//
// -----------------------------------------------------------------------

module Mux4To1
#(
    parameter WIDTH = 32)
(
    input  logic [1:0]       i_select,

    input  logic [WIDTH-1:0] i_input0,
    input  logic [WIDTH-1:0] i_input1,
    input  logic [WIDTH-1:0] i_input2,
    input  logic [WIDTH-1:0] i_input3,

    output logic [WIDTH-1:0] o_output);

    always_comb
        case (i_select)
            2'b00: o_output = i_input0;
            2'b01: o_output = i_input1;
            2'b10: o_output = i_input2;
            2'b11: o_output = i_input3;
        endcase

endmodule
