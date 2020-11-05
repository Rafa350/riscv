module mem
#(
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 32)
(
    input                   i_clk,
    input  [ADDR_WIDTH-1:0] i_addr,
    input                   i_we,
    input  [DATA_WIDTH-1:0] i_wr_data,
    output [DATA_WIDTH-1:0] o_rd_data);
    
    mw_ram _ram(
        .clock(i_clk),
        .wren(i_we),
        .data(i_wr_data),
        .q(o_rd_data),
        .rdaddress(i_addr),
        .wraddress(i_addr));
    
endmodule
