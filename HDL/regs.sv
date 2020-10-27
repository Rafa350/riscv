module regs
#(
    parameter DATA_WIDTH = 16,
    parameter INDEX_WIDTH = 3)
(
    input logic i_clk,                           // Clock
    
    input logic [INDEX_WIDTH-1:0] i_waddr,       // Write index
    input logic [DATA_WIDTH-1:0] i_wdata,        // Write data
    input logic i_we,                            // Write enable
    
    input logic [INDEX_WIDTH-1:0] i_raddr1,      // Read index 1
    output logic [DATA_WIDTH-1:0] o_rdata1,      // Read data 1
    
    input logic [INDEX_WIDTH-1:0] i_raddr2,      // Read index 2
    output logic [DATA_WIDTH-1:0] o_rdata2);     // Read data 2
    
    logic [DATA_WIDTH-1:0] data[0:(2^INDEX_WIDTH)-1];

    always_ff @(posedge i_clk)
        if (i_we)
            data[i_wdata] <= i_wdata;
            
    assign o_rdata1 = data[i_raddr1];
    assign o_rdata2 = data[i_raddr2];

endmodule
