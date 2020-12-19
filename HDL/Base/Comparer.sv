module Comparer
#(
    parameter WIDTH          = 32)       // Amplada de dades
(
    input  logic [WIDTH-1:0] i_inputA,   // Entrada per comparar A
    input  logic [WIDTH-1:0] i_inputB,   // Entrada per comparar B

    input  logic             i_unsigned, // Opera sense signe

    output logic             o_eq,     // A == B
    output logic             o_gt,     // A > B
    output logic             o_lt);    // A < B


    always_comb begin
        if (i_unsigned)
            o_gt  = i_inputA > i_inputB;
        else
            o_gt  = $signed(i_inputA) > $signed(i_inputB);
        o_eq = i_inputA == i_inputB;
        o_lt = !o_eq & !o_gt;
    end

endmodule
