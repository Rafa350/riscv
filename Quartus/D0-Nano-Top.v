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

    // -------------------------------------------------------------------
    // RAM: Memoria ram.
    //
    logic ram_we;
    ram #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(DATA_WIDTH))
    ram0 (
        .i_clk(clk),
        .i_wdata(ram_wdata),
        .o_rdata(ram_rdata),
        .i_we(ram_we),
        .i_addr(ram_addr));
      
    // -------------------------------------------------------------------
    // PGM: Programa.
    //    
    logic [PC_WIDTH-1:0] pgm_addr;
    logic [INST_WIDTH-1:0] pgm_inst;    
    pgm #(
        .ADDR_WIDTH(PC_WIDTH),
        .INST_WIDTH(INST_WIDTH))
    pgm0 (
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
    cpu0 (
        .i_clk(clk),
        .i_rst(rst),
        .o_pc(pgm_addr),
        .i_inst(pgm_inst),
        .o_mem_wr_enable(ram_we),
        .i_mem_rd_data(ram_rdata),
        .o_mem_wr_data(ram_wdata),
        .o_mem_addr(ram_addr));
       
endmodule
