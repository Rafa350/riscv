module Synchronizer
#(
    parameter WIDTH = 8)
(
    input  logic             i_clock,
    input  logic             i_reset,
    input  logic [WIDTH-1:0] i_input,
    output logic [WIDTH-1:0] o_output);

    logic [WIDTH-1:0] data;

    always_ff @(posedge i_clock)
        if (i_reset)
            {o_output, data} <= 'b0;
        else
            {o_output, data} <= {data, i_input};

endmodule
