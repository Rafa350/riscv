// verilator lint_off DECLFILENAME 


`ifdef VERILATOR
`include "types.sv"
`endif
 
 
`define DATA_DBUS_WIDTH 32
`define ADDR_DBUS_WIDTH 32
`define ADDR_IBUS_WIDTH 32
`define DATA_IBUS_WIDTH 32

`define PIPELINE


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
    
    RdBusInterface #(
        .DATA_WIDTH(DATA_DBUS_WIDTH),
        .ADDR_WIDTH(ADDR_DBUS_WIDTH))
    PgmBus();
    
    RdWrBusInterface #(
        .DATA_WIDTH(DATA_DBUS_WIDTH),
        .ADDR_WIDTH(ADDR_DBUS_WIDTH))
    MemBus();
    
    assign MemBus.RdData = i_ram_rdata;
    assign o_ram_addr    = MemBus.Addr;
    assign o_ram_wdata   = MemBus.WrData;
    assign o_ram_we      = MemBus.WrEnable;
 
    assign PgmBus.RdData = i_rom_rdata;
    assign o_rom_addr    = PgmBus.Addr;

`ifdef PIPELINE 
    ProcessorPP #(
`else
    ProcessorSC #(
`endif    
        .DATA_DBUS_WIDTH (DATA_DBUS_WIDTH), 
        .ADDR_DBUS_WIDTH (ADDR_DBUS_WIDTH),
        .DATA_IBUS_WIDTH (DATA_IBUS_WIDTH),
        .ADDR_IBUS_WIDTH (ADDR_IBUS_WIDTH)) 
    Cpu (
        .i_Clock       (i_Clock),
        .i_Reset       (i_Reset),
        .io_PgmBus     (PgmBus),
        .io_MemBus     (MemBus));
        
endmodule
