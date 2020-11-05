module mux8
#(
    parameter WIDTH = 32)
(
    input  logic [2:0]       i_sel,
    
    input  logic [WIDTH-1:0] i_in0,
    input  logic [WIDTH-1:0] i_in1,
    input  logic [WIDTH-1:0] i_in2,
    input  logic [WIDTH-1:0] i_in3,
    input  logic [WIDTH-1:0] i_in4,
    input  logic [WIDTH-1:0] i_in5,
    input  logic [WIDTH-1:0] i_in6,
    input  logic [WIDTH-1:0] i_in7,
    
    output logic [WIDTH-1:0] o_out);

    always_comb
        case (i_sel)
            3'b000: o_out = i_in0;
            3'b001: o_out = i_in1;
            3'b010: o_out = i_in2;
            3'b011: o_out = i_in3;
            3'b100: o_out = i_in4;
            3'b101: o_out = i_in5;
            3'b110: o_out = i_in6;
            3'b111: o_out = i_in7;
        endcase

endmodule