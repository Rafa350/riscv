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

`include "types.sv"
 
 
`define DATA_WIDTH 32
`define ADDR_WIDTH 32
`define PC_WIDTH   32
`define INST_WIDTH 32

`define SIM_ROM
`define SIM_RAM

 
module top(
`ifdef SIM_RAM
    input [`DATA_WIDTH-1:0] ram_rdata,
    output [`DATA_WIDTH-1:0] ram_wdata,
    output [`ADDR_WIDTH-1:0] ram_addr,
    output ram_we,
`endif
`ifdef SIM_ROM
    input [`INST_WIDTH-1:0] rom_rdata,
    output [`PC_WIDTH-1:0] rom_addr,
`endif
    input clk,
    input rst
);

    // Simulacio de la ram
    //
`ifndef SIM_RAM    
    logic [`DATA_WIDTH-1:0] ram_rdata;
    logic [`DATA_WIDTH-1:0] ram_wdata;
    logic [`ADDR_WIDTH-1:0] ram_addr;
    logic ram_we;
    logic [`DATA_WIDTH-1:0] data[0:15];
    
    always_ff @(posedge clk)    
        if (ram_we)
            data[ram_addr] <= ram_wdata;
    assign ram_rdata = data[ram_addr];
`endif    
    
    // CPU
    //
    cpu #(
        .DATA_WIDTH(`DATA_WIDTH), 
        .ADDR_WIDTH(`ADDR_WIDTH),
        .INST_WIDTH(`INST_WIDTH),
        .PC_WIDTH(`PC_WIDTH)) 
    cpu0 (
        .i_clk(clk),
        .i_rst(rst),
        .o_pc(rom_addr),
        .i_inst(rom_rdata),
        .o_mem_wr_enable(ram_we),  
        .i_mem_rd_data(ram_rdata),
        .o_mem_wr_data(ram_wdata),
        .o_mem_addr(ram_addr));
        
endmodule
