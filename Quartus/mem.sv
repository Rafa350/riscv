module mem
#(
    parameter DATA_WIDTH = 16,
    parameter ADDR_WIDTH = 16)
(
    input                   i_clk,
    input  [ADDR_WIDTH-1:0] i_addr,
    input                   i_we,
    input  [DATA_WIDTH-1:0] i_wdata,
    output [DATA_WIDTH-1:0] o_rdata);
    
    mw_ram _ram(
        .clock(i_clk),
        .wren(i_we),
        .data(i_wdata),
        .q(o_rdata),
        .rdaddress(i_addr),
        .wraddress(i_addr));
    
endmodule
