module ram
#(
    parameter DATA_WIDTH = 16,
    parameter ADDR_WIDTH = 16)
(
    input wire i_clk,
    input wire [ADDR_WIDTH-1:0] i_addr,
    input wire i_we,
    input wire [DATA_WIDTH-1:0] i_wdata,
    output wire [DATA_WIDTH-1:0] o_rdata);
    
    mw_ram _ram(
        .clock(i_clk),
        .wren(i_we),
        .data(i_wdata),
        .q(o_rdata),
        .rdaddress(i_addr),
        .wraddress(i_addr));
    
endmodule
