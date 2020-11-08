module Comparer 
#(
    parameter WIDTH          = 32)
(
    input  logic [WIDTH-1:0] i_InputA,
    input  logic [WIDTH-1:0] i_InputB,
    
    output logic             o_EQ,
    output logic             o_GZ,
    output logic             o_LZ,
    output logic             o_GEZ,
    output logic             o_LEZ);

    logic IsZeroA;

    assign IsZeroA = ~|i_InputA;

    always_comb begin
        o_EQ  = i_InputA == i_InputB;
        o_GZ  = ~i_InputA[WIDTH-1] & ~IsZeroA;
        o_LZ  = i_InputA[WIDTH-1];
        o_GEZ = ~i_InputA[WIDTH-1];
        o_LEZ = i_InputA[WIDTH-1] | IsZeroA;
    end
    
endmodule

    
    