// -----------------------------------------------------------------------
//
//       Semi-sumador
//
//       Parametres:
//           WIDTH      : Amplada del canal de dades en bits
//
//       Entrada:
//           i_operandA : Oparans A
//           i_operandB : Operand B
//
//       Sortida:
//           o_result   : Resultat de la suma
//
// -----------------------------------------------------------------------

module HalfAdder
#(
    parameter WIDTH = 32)                // Amplada de dades
(
    input  logic [WIDTH-1:0] i_operandA, // Operand A
    input  logic [WIDTH-1:0] i_operandB, // Operand B

    output logic [WIDTH-1:0] o_result);  // El resultat de l'operacio (A + B)

    assign o_result = i_operandA + i_operandB;

endmodule
