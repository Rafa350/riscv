// -----------------------------------------------------------------------
//
//       Multiplextor de 2 a 1
//
//       Parametres:
//            WIDTH     : Amplada del canal de dades
//
//       Entrades:
//            i_Select  : Seleccio del canal d'entrada
//            i_Input0  : Canal d'entrada 0
//            i_Input1  : Canal d'entrada 1
//            i_Input2  : Canal d'entrada 2
//            i_Input3  : Canal d'entrada 3
//
//       Sortides:
//            o_Output  : El valor de l'entrada seleccionada.
//
// -----------------------------------------------------------------------

module Mux4To1
#(
    parameter WIDTH = 32)
(
    input  logic [1:0]       i_Select,

    input  logic [WIDTH-1:0] i_Input0,
    input  logic [WIDTH-1:0] i_Input1,
    input  logic [WIDTH-1:0] i_Input2,
    input  logic [WIDTH-1:0] i_Input3,

    output logic [WIDTH-1:0] o_Output);

    always_comb
        unique case (i_Select)
            2'b00: o_Output = i_Input0;
            2'b01: o_Output = i_Input1;
            2'b10: o_Output = i_Input2;
            2'b11: o_Output = i_Input3;
        endcase

endmodule