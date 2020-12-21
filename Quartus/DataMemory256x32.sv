module DataMemory256x32
    import Types::*;
(
    input               i_clock,
    DataMemoryBus.slave bus);
    
    // Els modul de ram es de 256x32 bits
    mw_ram 
    ram0(
        .clock     (i_clock),
        .wren      (bus.wrEnable),
        .data      (bus.wrData),
        .q         (bus.rdData),
        .rdaddress (bus.addr[9:2]),
        .wraddress (bus.addr[9:2]));
        
endmodule
