module test
#(
    parameter WIDTH = 32)
(
    input  [WIDTH-1:0] i_inA,
    input  [WIDTH-1:0] i_inB,
    
    output o_eq,
    output o_gz,
    output o_lz,
    output o_gez,
    output o_lez
    );

    logic zeroA = (i_inA == 32'b0);

    assign o_eq  = (i_inA == i_inB);
    assign o_gz  = (~i_inA[WIDTH-1] & ~zeroA);
    assign o_lz  = i_inA[WIDTH-1];
    assign o_gez = ~i_inA[WIDTH-1];
    assign o_lez = (i_inA[WIDTH-1] | zeroA);
    
endmodule
