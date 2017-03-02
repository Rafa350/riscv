module ram
#(
    parameter DATA_WIDTH = 16,
    parameter ADDR_WIDTH = 6)
(
    input wire clk,
    input wire [ADDR_WIDTH-1:0] raddr,
    input wire [ADDR_WIDTH-1:0] waddr,
    input wire we,
    input wire [DATA_WIDTH-1:0] din,
    output wire [DATA_WIDTH-1:0] dout);
    
    mw_ram _ram(
        .clock(clk),
        .wren(we),
        .data(din),
        .q(dout),
        .rdaddress(raddr),
        .wraddress(waddr));
    
endmodule
