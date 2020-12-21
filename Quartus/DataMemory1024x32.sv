module DataMemory1024x32
    import Types::*;
(
    input               i_clock, // Clock
    DataMemoryBus.slave bus);    // Bus de memoria de dades
    
    localparam ADDR_WIDTH = $size(bus.addr);
    localparam DATA_WIDTH = $size(bus.rdData);
    
    // Els moduls de ram son de 256x32 bits
    // S'utilitzen 4 m oduls per completar els 1024x32 bits
    // Es seleccionen els blocs pels bits baixos per repartir
    // millor les dades en els blocs

    Data data[0:3];
    logic [ADDR_WIDTH-3:0] addr;
    logic [3:0] we;
    
    mw_ram 
    ram0(
        .clock     (i_clock),
        .wren      (we[0]),
        .data      (bus.wrData),
        .q         (data[0]),
        .rdaddress (addr[7:0]),
        .wraddress (addr[7:0]));
    mw_ram 

    ram1(
        .clock     (i_clock),
        .wren      (we[1]),
        .data      (bus.wrData),
        .q         (data[1]),
        .rdaddress (addr[7:0]),
        .wraddress (addr[7:0]));
    mw_ram 

    ram2(
        .clock     (i_clock),
        .wren      (we[2]),
        .data      (bus.wrData),
        .q         (data[2]),
        .rdaddress (addr[7:0]),
        .wraddress (addr[7:0]));
    mw_ram 

    ram3(
        .clock     (i_clock),
        .wren      (we[3]),
        .data      (bus.wrData),
        .q         (data[3]),
        .rdaddress (addr[7:0]),
        .wraddress (addr[7:0]));

    always_comb begin
        addr = bus.addr[ADDR_WIDTH-1:2];
        unique case (bus.addr[1:0])
            2'b00: we = {1'b0, 1'b0, 1'b0, bus.wrEnable};
            2'b01: we = {1'b0, 1'b0, bus.wrEnable, 1'b0};
            2'b10: we = {1'b0, bus.wrEnable, 1'b0, 1'b0};
            2'b11: we = {bus.wrEnable, 1'b0, 1'b0, 1'b0};
        endcase
    end

    assign bus.rdData = data[bus.addr[1:0]];
        
endmodule
