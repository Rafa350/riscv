module test
#(
    parameter WIDTH = 32)
(
    input  [WIDTH-1:0] i_in1,
    input  [WIDTH-1:0] i_in2,
    
    output o_eq,
    output o_gz,
    output o_lz,
    output o_gez,
    output o_lez
    );

    logic zeroA = (i_in1 == 32'b0);

    assign o_eq  = (i_in1 == i_in2);
    assign o_gz  = (~i_in1[WIDTH-1] & ~zeroA);
    assign o_lz  = i_in1[WIDTH-1];
    assign o_gez = ~i_in1[WIDTH-1];
    assign o_lez = (i_in1[WIDTH-1] | zeroA);
    
endmodule
