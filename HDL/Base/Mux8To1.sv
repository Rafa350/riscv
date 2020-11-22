// -----------------------------------------------------------------------
//
//       Multiplexor de 2 a 1
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
//            i_Input4  : Canal d'entrada 4
//            i_Input5  : Canal d'entrada 5
//            i_Input6  : Canal d'entrada 6
//            i_Input7  : Canal d'entrada 7
//
//       Sortides:
//            o_Output  : El valor de l'entrada seleccionada.
//
// -----------------------------------------------------------------------

module Mux8To1
#(
    parameter WIDTH = 32)
(
    input  logic [2:0]       i_Select,

    input  logic [WIDTH-1:0] i_Input0,
    input  logic [WIDTH-1:0] i_Input1,
    input  logic [WIDTH-1:0] i_Input2,
    input  logic [WIDTH-1:0] i_Input3,
    input  logic [WIDTH-1:0] i_Input4,
    input  logic [WIDTH-1:0] i_Input5,
    input  logic [WIDTH-1:0] i_Input6,
    input  logic [WIDTH-1:0] i_Input7,

    output logic [WIDTH-1:0] o_Output);

    always_comb
        unique case (i_Select)
            3'b000: o_Output = i_Input0;
            3'b001: o_Output = i_Input1;
            3'b010: o_Output = i_Input2;
            3'b011: o_Output = i_Input3;
            3'b100: o_Output = i_Input4;
            3'b101: o_Output = i_Input5;
            3'b110: o_Output = i_Input6;
            3'b111: o_Output = i_Input7;
        endcase

endmodule