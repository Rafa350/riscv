module regs
#(
    parameter DATA_WIDTH = 32,
    parameter INDEX_WIDTH = 5)
(
    input logic i_clk,                           // Clock
    input logic i_rst,                           // Reset
    
    input logic [INDEX_WIDTH-1:0] i_wr_index,    // Write index
    input logic [DATA_WIDTH-1:0] i_wr_data,      // Write data
    input logic i_wr_enable,                     // Write enable
    
    input logic [INDEX_WIDTH-1:0] i_rd_index1,   // Read index 1
    output logic [DATA_WIDTH-1:0] o_rd_data1,    // Read data 1
    
    input logic [INDEX_WIDTH-1:0] i_rd_index2,   // Read index 2
    output logic [DATA_WIDTH-1:0] o_rd_data2);   // Read data 2
    
    logic [DATA_WIDTH-1:0] data[1:(2**INDEX_WIDTH)-1];
    logic [DATA_WIDTH-1:0] zero = 0;

    always_ff @(posedge i_clk)
        if (i_rst) begin
            integer i;
            for (i = 1; i < 2**INDEX_WIDTH; i++)
                data[i] <= 0;
        end                
        else if (i_wr_enable & (~|i_wr_index))
            data[i_wr_index] <= i_wr_data;
            
    assign o_rd_data1 = ~|i_rd_index1 ? zero : data[i_rd_index1];
    assign o_rd_data2 = ~|i_rd_index2 ? zero : data[i_rd_index2];

endmodule
