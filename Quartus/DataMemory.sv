module DataMemory
#(
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 32)
(
    input               i_Clock,
    DataMemoryBus.Slave DBus);
   
    mw_ram ram(
        .clock     (i_Clock),
        .wren      (DBus.WrEnable),
        .data      (DBus.WrData),
        .q         (DBus.RdData),
        .rdaddress (DBus.Addr[ADDR_WIDTH-1:2]),
        .wraddress (DBus.Addr[ADDR_WIDTH-1:2]));

endmodule
