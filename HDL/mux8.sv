module mux8
#(
    parameter WIDTH = 32)
(
    input  logic [2:0]       i_sel,
    
    input  logic [WIDTH-1:0] i_in_0,
    input  logic [WIDTH-1:0] i_in_1,
    input  logic [WIDTH-1:0] i_in_2,
    input  logic [WIDTH-1:0] i_in_3,
    input  logic [WIDTH-1:0] i_in_4,
    input  logic [WIDTH-1:0] i_in_5,
    input  logic [WIDTH-1:0] i_in_6,
    input  logic [WIDTH-1:0] i_in_7,
    
    output logic [WIDTH-1:0] o_out);

    always_comb
        case (i_sel)
            3'b000: o_out = i_in_0;
            3'b001: o_out = i_in_1;
            3'b010: o_out = i_in_2;
            3'b011: o_out = i_in_3;
            3'b100: o_out = i_in_4;
            3'b101: o_out = i_in_5;
            3'b110: o_out = i_in_6;
            3'b111: o_out = i_in_7;
        endcase

endmodule