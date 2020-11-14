module HalfAdder
#(
    parameter WIDTH          = 32)       // Amplada de dades
(
    input  logic [WIDTH-1:0] i_OperandA, // Operand A
    input  logic [WIDTH-1:0] i_OperandB, // Operand B

    output logic [WIDTH-1:0] o_Result);  // El resultat de l'operacio (A + B)

    assign o_Result = i_OperandA + i_OperandB;

endmodule
