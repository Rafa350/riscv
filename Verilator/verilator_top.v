// verilator lint_off DECLFILENAME 


`include "types.sv"
 
 
`define DATA_DBUS_WIDTH 32
`define ADDR_DBUS_WIDTH 32
`define ADDR_IBUS_WIDTH 32
`define DATA_IBUS_WIDTH 32

//`define PIPELINE


module top #(
    parameter DATA_DBUS_WIDTH = `DATA_DBUS_WIDTH,
    parameter ADDR_DBUS_WIDTH = `ADDR_DBUS_WIDTH,
    parameter DATA_IBUS_WIDTH = `DATA_IBUS_WIDTH,
    parameter ADDR_IBUS_WIDTH = `ADDR_IBUS_WIDTH)
(
    input                        i_Clock,
    input                        i_Reset,

    input  [DATA_DBUS_WIDTH-1:0] i_ram_rdata,
    output [DATA_DBUS_WIDTH-1:0] o_ram_wdata,
    output [ADDR_DBUS_WIDTH-1:0] o_ram_addr,
    output                       o_ram_we,

    input  [DATA_IBUS_WIDTH-1:0] i_rom_rdata,
    output [ADDR_IBUS_WIDTH-1:0] o_rom_addr );
 
`ifdef PIPELINE 
    cpu_pipeline #(
`else
    cpu #(
`endif    
        .DATA_DBUS_WIDTH (DATA_DBUS_WIDTH), 
        .ADDR_DBUS_WIDTH (ADDR_DBUS_WIDTH),
        .DATA_IBUS_WIDTH (DATA_IBUS_WIDTH),
        .ADDR_IBUS_WIDTH (ADDR_IBUS_WIDTH)) 
    Cpu (
        .i_Clock       (i_Clock),
        .i_Reset       (i_Reset),
        .o_PgmAddr     (o_rom_addr),
        .i_PgmInst     (i_rom_rdata),
        .o_MemWrEnable (o_ram_we),  
        .i_MemRdData   (i_ram_rdata),
        .o_MemWrData   (o_ram_wdata),
        .o_MemAddr     (o_ram_addr));
        
endmodule
