module ComparerZero
#(
    parameter WIDTH          = 32)
(
    input  logic [WIDTH-1:0] i_Input,  // Entrada per comparar
    
    output logic             o_EQ,     // Input == 0
    output logic             o_GZ,     // Input > 0
    output logic             o_LZ,     // Input < 0
    output logic             o_GEZ,    // Input >= 0
    output logic             o_LEZ);   // Input <= 0

    logic IsZero;
    assign IsZero = ~|i_Input;

    always_comb begin
        o_EQ  = IsZero;
        o_GZ  = ~i_Input[WIDTH-1] & ~IsZero;
        o_LZ  = i_Input[WIDTH-1];
        o_GEZ = ~i_Input[WIDTH-1];
        o_LEZ = i_Input[WIDTH-1] | IsZero;
    end
    
endmodule

    
    