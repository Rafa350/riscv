module mux4
#(
    parameter WIDTH = 32)
(
    input  logic [1:0]       i_sel,
    
    input  logic [WIDTH-1:0] i_in0,
    input  logic [WIDTH-1:0] i_in1,
    input  logic [WIDTH-1:0] i_in2,
    input  logic [WIDTH-1:0] i_in3,
    
    output logic [WIDTH-1:0] o_out);

    always_comb
        case (i_sel)
            2'b00: o_out = i_in0;
            2'b01: o_out = i_in1;
            2'b10: o_out = i_in2;
            2'b11: o_out = i_in3;
        endcase

endmodule