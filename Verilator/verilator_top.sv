// verilator lint_off DECLFILENAME 


`ifdef VERILATOR
`include "types.sv"
`endif
 
 
`define DATA_WIDTH 32
`define ADDR_WIDTH 32
`define PC_WIDTH   32
`define REG_WIDTH  5

//`define PIPELINE


module top #(
    parameter DATA_WIDTH = `DATA_WIDTH,
    parameter ADDR_WIDTH = `ADDR_WIDTH,
    parameter PC_WIDTH   = `PC_WIDTH)
(
    input                   i_Clock,
    input                   i_Reset,

    input  [DATA_WIDTH-1:0] i_ram_rdata,
    output [DATA_WIDTH-1:0] o_ram_wdata,
    output [ADDR_WIDTH-1:0] o_ram_addr,
    output                  o_ram_we,

    input  [31:0]           i_rom_rdata,
    output [PC_WIDTH-1:0]   o_rom_addr);
    
`ifdef PIPELINE 
    ProcessorPP #(
`else
    ProcessorSC #(
`endif    
        .DATA_WIDTH (DATA_WIDTH), 
        .ADDR_WIDTH (ADDR_WIDTH),
        .PC_WIDTH   (PC_WIDTH)) 
    Cpu (
        .i_Clock       (i_Clock),
        .i_Reset       (i_Reset),
        .o_PgmAddr     (o_rom_addr),
        .i_PgmInst     (i_rom_rdata),
        .o_MemAddr     (o_ram_addr),
        .o_MemWrEnable (o_ram_we),
        .o_MemWrData   (o_ram_wdata),
        .i_MemRdData   (i_ram_rdata));
        
endmodule
