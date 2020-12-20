module Comparer
#(
    parameter WIDTH          = 32)       // Amplada de dades
(
    input  logic [WIDTH-1:0] i_inputA,   // Entrada per comparar A
    input  logic [WIDTH-1:0] i_inputB,   // Entrada per comparar B

    input  logic             i_unsigned, // Opera sense signe

    output logic             o_equal,    // A == B
    output logic             o_greater,  // A > B
    output logic             o_less);    // A < B


    always_comb begin
        if (i_unsigned)
            o_greater  = i_inputA > i_inputB;
        else
            o_greater  = $signed(i_inputA) > $signed(i_inputB);
        o_equal = i_inputA == i_inputB;
        o_less = !o_equal & !o_greater;
    end

endmodule
