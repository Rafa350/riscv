// -----------------------------------------------------------------------
//
//       Multiplexor de 2 a 1
//
//       Parametres:
//            WIDTH     : Amplada del canal de dades
//
//       Entrades:
//            i_select  : Seleccio del canal d'entrada
//            i_input0  : Canal d'entrada 0
//            i_input1  : Canal d'entrada 1
//
//       Sortides:
//            o_output  : El valor de l'entrada seleccionada.
//
// -----------------------------------------------------------------------

module Mux2To1
#(
    parameter WIDTH = 32)
(
    input  logic             i_select,

    input  logic [WIDTH-1:0] i_input0,
    input  logic [WIDTH-1:0] i_input1,

    output logic [WIDTH-1:0] o_output);

    assign o_output = i_select ? i_input1 : i_input0;

endmodule
