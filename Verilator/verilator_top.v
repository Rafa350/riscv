/*************************************************************************
 *
 *       Modul TOP per Verilator
 *
 *       Entradas
 *           clk : Clock
 *           rst : Reset
 *
 *************************************************************************/

 
/* verilator lint_off DECLFILENAME */
/* verilator lint_off UNUSED */
/* verilator lint_off PINMISSING */
 
 
`define RAM_DATA_WIDTH 16
`define RAM_ADDR_WIDTH 8
`define ROM_DATA_WIDTH 16
`define ROM_ADDR_WIDTH 12
`define IO_DATA_WIDTH 8

`define SIM_ROM

`timescale 1 ns/ 1ns

 
module top(
`ifdef SIM_RAM
    input [`RAM_DATA_WIDTH-1:0] ram_din,
    output [`RAM_DATA_WIDTH-1:0] ram_out,
    output [`RAM_ADDR_WIDTH-1:0] ram_addr,
    output ram_we,
`endif
`ifdef SIM_ROM
    input [`ROM_DATA_WIDTH-1:0] rom_din,
    output [`ROM_ADDR_WIDTH-1:0] rom_addr,
`endif
`ifdef SIM_IO
    input [`IO_DATA_WIDTH-1:0] io_din,
    output [`IO_DATA_WIDTH-1:0] io_dout,
    input io_we,
`endif    
    input clk,
    input rst
);

    cpu #(
        .RAM_DATA_WIDTH(`RAM_DATA_WIDTH), 
        .RAM_ADDR_WIDTH(`RAM_ADDR_WIDTH),
        .ROM_DATA_WIDTH(`ROM_DATA_WIDTH),
        .ROM_ADDR_WIDTH(`ROM_ADDR_WIDTH)) 
    _cpu(
        .i_clk(clk),
        .i_rst(rst),
        .rom_din(rom_din),
        .rom_addr(rom_addr));
        
endmodule
