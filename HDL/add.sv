module add
#(
    parameter WIDTH = 32)
(
    input logic [WIDTH-1:0] i_inA,
    input logic [WIDTH-1:0] i_inB,
    
    output logic [WIDTH-1:0] o_out);

    assign o_out = a_inA + i_inB;
    
endmodule