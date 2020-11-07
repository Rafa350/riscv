module comparer 
#(
    parameter WIDTH          = 32)
(
    input  logic [WIDTH-1:0] i_inA,
    input  logic [WIDTH-1:0] i_inB,
    
    output logic             o_eq,
    output logic             o_gz,
    output logic             o_lz,
    output logic             o_gez,
    output logic             o_lez);

    logic zeroA;

    assign zeroA = i_inA == {WIDTH{1'b0}};

    always_comb begin
        o_eq  = i_inA == i_inB;
        o_gz  = ~i_inA[WIDTH-1] & ~zeroA;
        o_lz  = i_inA[WIDTH-1];
        o_gez = ~i_inA[WIDTH-1];
        o_lez = i_inA[WIDTH-1] | zeroA;
    end
    
endmodule

    
    