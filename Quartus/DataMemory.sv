module DataMemory
#(
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 32)
(
    input               i_clock,
    DataMemoryBus.slave bus);
   
    mw_ram ram(
        .clock     (i_clock),
        .wren      (bus.wrEnable),
        .data      (bus.wrData),
        .q         (bus.rdData),
        .rdaddress (bus.addr[ADDR_WIDTH-1:2]),
        .wraddress (bus.addr[ADDR_WIDTH-1:2]));

endmodule
