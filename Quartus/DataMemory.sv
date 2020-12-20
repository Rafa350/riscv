module DataMemory
    import Types::*;
(
    input               i_clock,
    DataMemoryBus.slave bus);
    
    localparam DATA_WIDTH = $size(bus.addr);
   
    mw_ram ram(
        .clock     (i_clock),
        .wren      (bus.wrEnable),
        .data      (bus.wrData),
        .q         (bus.rdData),
        .rdaddress (bus.addr[DATA_WIDTH-1:2]),
        .wraddress (bus.addr[DATA_WIDTH-1:2]));

endmodule
