//`define PIPELINE


module top(
    input  wire       CLOCK_50,
    input  wire [1:0] KEY,
    input  wire [3:0] SW,
    output wire [7:0] LED);
    
    parameter DATA_DBUS_WIDTH = 32;
    parameter ADDR_DBUS_WIDTH = 32;
    parameter DATA_IBUS_WIDTH = 32;
    parameter ADDR_IBUS_WIDTH = 32;
    
    logic Clock;
    assign Clock = ~KEY[0];

    logic Reset;
    assign Reset = ~KEY[1];
       
    RdWrBusInterface #(
        .DATA_WIDTH (DATA_DBUS_WIDTH),
        .ADDR_WIDTH (ADDR_DBUS_WIDTH))
    MemBus();
    
    RdBusInterface #(
        .DATA_WIDTH (DATA_IBUS_WIDTH),
        .ADDR_WIDTH (ADDR_IBUS_WIDTH))
    PgmBus();
    
    assign LED[7:6] = PgmBus.Addr[1:0];
    assign LED[5:0] = PgmBus.RdData[31:26];
    
    // ------------------------------------------------------------------
    // Port IO
    //


    // -------------------------------------------------------------------
    // Memoria RAM
    //
    mem #(
        .DATA_WIDTH (DATA_DBUS_WIDTH),
        .ADDR_WIDTH (DATA_DBUS_WIDTH))
    mem (
        .i_Clock   (Clock),
        .io_MemBus (MemBus));

      
    // -------------------------------------------------------------------
    // Memoria de programa
    //     
    pgm #(
        .ADDR_WIDTH (ADDR_IBUS_WIDTH),
        .INST_WIDTH (DATA_IBUS_WIDTH))
    pgm (
        .io_PgmBus (PgmBus));


    // -------------------------------------------------------------------
    // CPU
    //
    
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
        .i_Clock   (Clock),
        .i_Reset   (Reset),
        .io_PgmBus (PgmBus),
        .io_MemBus (MemBus));
       
endmodule
