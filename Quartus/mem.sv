module mem
#(
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 32)
(
    input                  i_Clock,
    RdWrBusInterface.Slave io_MemBus);
    
    mw_ram _ram(
        .clock(i_Clock),
        .wren(io_MemBus.WrEnable),
        .data(io_MemBus.WrData),
        .q(io_MemBus.RdData),
        .rdaddress(io_MemBus.Addr),
        .wraddress(io_MemBus.Addr));
    
endmodule
