module DataMemory1024x32
    import 
        Config::*,
        ProcessorDefs::*;
(
    input         i_clock, // Clock
    DataBus.slave bus);    // Bus de memoria de dades
          
    assign     bus.busy = 1'b0;
      

    // Ram pels bits [7:0]
    ram1024x8 
    ram0(
        .clock     (i_clock),
        .address   (bus.addr[11:2]),
        .wren      (bus.be[0] & bus.we),
        .data      (bus.wdata[7:0]),
        .q         (bus.rdata[7:0]));
        
    // Ram pels bits [15:8]
    ram1024x8 
    ram1(
        .clock     (i_clock),
        .address   (bus.addr[11:2]),
        .wren      (bus.be[1] & bus.we),
        .data      (bus.wdata[15:8]),
        .q         (bus.rdata[15:8]));

    // Ram pels bits [23:16]
    ram1024x8 
    ram2(
        .clock     (i_clock),
        .address   (bus.addr[11:2]),
        .wren      (bus.be[2] & bus.we),
        .data      (bus.wdata[23:16]),
        .q         (bus.rdata[23:16]));

    // Ram pels bits [31:24]
    ram1024x8 
    ram3(
        .clock     (i_clock),
        .address   (bus.addr[11:2]),
        .wren      (bus.be[3] & bus.we),
        .data      (bus.wdata[31:24]),
        .q         (bus.rdata[31:24]));        

endmodule
