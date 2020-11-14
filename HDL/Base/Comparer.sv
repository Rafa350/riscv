module Comparer 
#(
    parameter WIDTH          = 32)       // Amplada de dades
(
    input  logic [WIDTH-1:0] i_InputA,   // Entrada per comparar A
    input  logic [WIDTH-1:0] i_InputB,   // Entrada per comparar B
    
// verilator lint_off UNUSED     
    input  logic             i_Unsigned, // Opera sense signe
// verilator lint_on UNUSED     
    
    output logic             o_EQ,     // A == B
    output logic             o_GT,     // A > B
    output logic             o_LT);    // A < B

    always_comb begin
        o_EQ  = i_InputA == i_InputB;
        o_GT  = i_InputA > i_InputB;
        o_LT  = i_InputA < i_InputB;
    end
    
endmodule

    
    