module half_adder
#(
    parameter WIDTH = 32)
(
    input logic [WIDTH-1:0] i_in_A,
    input logic [WIDTH-1:0] i_in_B,
    
    output logic [WIDTH-1:0] o_out);

    assign o_out = a_in_A + i_in_B;
    
endmodule