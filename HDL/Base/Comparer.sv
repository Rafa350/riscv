module Comparer 
#(
    parameter WIDTH          = 32)       // Amplada de dades
(
    input  logic [WIDTH-1:0] i_InputA,   // Entrada per comparar A
    input  logic [WIDTH-1:0] i_InputB,   // Entrada per comparar B
    
    input  logic             i_Unsigned, // Opera sense signe
    
    output logic             o_EQ,     // A == B
    output logic             o_GT,     // A > B
    output logic             o_LT);    // A < B
      

    always_comb begin
        if (i_Unsigned) 
            o_GT  = i_InputA > i_InputB;
        else
            o_GT  = $signed(i_InputA) > $signed(i_InputB);
        o_EQ = i_InputA == i_InputB;
        o_LT = !o_EQ & !o_GT;
    end

endmodule
