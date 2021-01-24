module CacheMem
#(
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 32)
(
    input  logic            i_clock,
    input  logic            i_wr,
    input  [ADDR_WIDTH-1:0] i_addr,
    input  [DATA_WIDTH-1:0] i_data,
    output [DATA_WIDTH-1:0] o_data);


    localparam DATA_SIZE = 2**ADDR_WIDTH;


    logic [DATA_WIDTH-1:0] data[DATA_SIZE];


    always_ff @(posedge i_clock)
        if (i_wr)
            data[i_addr] = i_data;

    assign o_data = data[i_addr];

endmodule