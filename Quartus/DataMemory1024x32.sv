module DataMemory1024x32
    import Types::*;
(
    input               i_clock, // Clock
    DataMemoryBus.slave bus);    // Bus de memoria de dades
    
    localparam ADDR_WIDTH = $size(bus.addr);
    localparam DATA_WIDTH = $size(bus.rdData);
    
    // Els moduls de ram son de 1024x8 bits
    // S'utilitzen 4 moduls per completar els 1024x32 bits
    // Es seleccionen els blocs pels bits baixos per repartir
    // millor les dades en els blocs

    Data data[0:3];
    logic [ADDR_WIDTH-3:0] addr;
    logic [3:0] we;
    
    ram1024x8 
    ram0(
        .clock     (i_clock),
        .address   (bus.addr[11:2]),
        .wren      (~bus.addr[1] & ~bus.addr[0] & bus.wrMask[0] & bus.wrEnable),
        .data      (bus.wrData[7:0]),
        .q         (bus.rdData[7:0]));
        
    ram1024x8 
    ram1(
        .clock     (i_clock),
        .address   (bus.addr[11:2]),
        .wren      (~bus.addr[1] & bus.addr[0] & bus.wrMask[1] & bus.wrEnable),
        .data      (bus.wrData[15:8]),
        .q         (bus.rdData[15:8]));

    ram1024x8 
    ram2(
        .clock     (i_clock),
        .address   (bus.addr[11:2]),
        .wren      (bus.addr[1] & ~bus.addr[0] & bus.wrMask[2] & bus.wrEnable),
        .data      (bus.wrData[23:16]),
        .q         (bus.rdData[23:16]));

    ram1024x8 
    ram3(
        .clock     (i_clock),
        .address   (bus.addr[11:2]),
        .wren      (bus.addr[1] & bus.addr[0] & bus.wrMask[3] & bus.wrEnable),
        .data      (bus.wrData[31:24]),
        .q         (bus.rdData[31:24]));

endmodule
