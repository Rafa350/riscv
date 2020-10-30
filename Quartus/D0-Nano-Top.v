module top(
    input wire CLOCK_50,
    input wire [1:0] KEY,
    input wire [3:0] SW,
    output wire [7:0] LED);
    
    parameter DATA_WIDTH = 32;
    parameter ADDR_WIDTH = 32;
    parameter PC_WIDTH   = 32;
    parameter INST_WIDTH = 32;
    
    logic clk;
    assign clk = ~KEY[0];

    logic rst;
    assign rst = ~KEY[1];
    
    logic [PC_WIDTH-1:0] pgm_addr;
    logic [INST_WIDTH-1:0] pgm_inst;    

    logic [DATA_WIDTH-1:0] mem_wdata;
    logic [DATA_WIDTH-1:0] mem_rdata;
    logic [ADDR_WIDTH-1:0] mem_addr;
    
    assign LED[3:0] = mem_wdata[3:0];
    assign LED[6:4] = pgm_addr[2:0];
    assign LED[7]   = mem_we;

    // -------------------------------------------------------------------
    // RAM: Memoria ram.
    //
    logic ram_we;
    mem #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(DATA_WIDTH))
    mem (
        .i_clk(clk),
        .i_we(mem_we),
        .i_addr(mem_addr),
        .i_wdata(mem_wdata),
        .o_rdata(mem_rdata));
      
    // -------------------------------------------------------------------
    // PGM: Programa.
    //    
    pgm #(
        .ADDR_WIDTH(PC_WIDTH),
        .INST_WIDTH(INST_WIDTH))
    pgm (
        .i_addr(pgm_addr),
        .o_inst(pgm_inst));

    // -------------------------------------------------------------------
    // CPU
    //
    cpu #(
        .DATA_WIDTH(DATA_WIDTH), 
        .ADDR_WIDTH(ADDR_WIDTH),
        .INST_WIDTH(INST_WIDTH),
        .PC_WIDTH(PC_WIDTH)) 
    cpu (
        .i_clk(clk),
        .i_rst(rst),
        .o_pc(pgm_addr),
        .i_inst(pgm_inst),
        .o_mem_wr_enable(mem_we),  
        .i_mem_rd_data(mem_rdata),
        .o_mem_wr_data(mem_wdata),
        .o_mem_addr(mem_addr));
       
endmodule
