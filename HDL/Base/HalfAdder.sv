// -----------------------------------------------------------------------
//
//       Semi-sumador
//
//       Parametres:
//           WIDTH    : Amplada del canal de dades en bits
//
//       Entrada:
//           i_inputA : Oparand A
//           i_inputB : Operand B
//
//       Sortida:
//           o_output : Resultat de la suma
//
// -----------------------------------------------------------------------

module HalfAdder
#(
    parameter WIDTH = 32)                // Amplada de dades
(
    input  logic [WIDTH-1:0] i_inputA,   // Operand A
    input  logic [WIDTH-1:0] i_inputB,   // Operand B

    output logic [WIDTH-1:0] o_output);  // El resultat de l'operacio (A + B)

    assign o_output = i_inputA + i_inputB;

endmodule
