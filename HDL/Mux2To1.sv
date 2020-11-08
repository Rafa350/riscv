module Mux2To1
#(
    parameter WIDTH = 32)
(
    input  logic             i_Select,
    
    input  logic [WIDTH-1:0] i_Input0,
    input  logic [WIDTH-1:0] i_Input1,
    
    output logic [WIDTH-1:0] o_Output);

    assign o_Output = i_Select ? i_Input1 : i_Input0;

endmodule