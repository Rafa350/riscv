module Synchronizer
#(
    parameter WIDTH = 8)
(
    input  logic             i_clock,
    input  logic             i_reset,
    input  logic [WIDTH-1:0] i_data,
    output logic [WIDTH-1:0] o_data);

    logic [WIDTH-1:0] data;

    always_ff @(posedge i_clock)
        if (i_reset)
            {o_data, data} <= 'b0;
        else
            {o_data, data} <= {data, i_data};

endmodule
