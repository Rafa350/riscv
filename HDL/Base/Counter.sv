module Counter
#(
    parameter WIDTH = 32,
    parameter INIT  = 32'd0)
(
    input  logic             i_clock,
    input  logic             i_reset,
    input  logic             i_ce,
    output logic [WIDTH-1:0] o_count);


    always_ff @(posedge i_clock)
        case ({i_reset, i_ce])
            2'b00: o_count <= o_count;
            2'b01: o_count <= o_count + 1;
            2'b10: o_count <= INIT;
            2'b11: o_count <= INIT;
        endcase

endmodule
