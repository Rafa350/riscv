module DataMemory
    import Types::*;
(
    input logic         i_clock,
    DataMemoryBus.slave bus);

    localparam DATA_WIDTH = $size(bus.data);
    localparam ADDR_WIDTH = $size(bus.addr);
    
    logic [1:0] byteAddr;
    logic [29:0] wordAddr;
    
    assign byteAddr = bus.addr[1:0];
    assign wordAddr = bus.addr[31:2];

    RwMemory #(
        .DATA_WIDTH (DATA_WIDTH),
        .ADDR_WIDTH (ADDR_WIDTH-2))
    memoryB0 (
        .i_Clock    (i_clock),
        .i_Addr     (wordAddr),
        .o_RdAddr   (bus.rdData[7:0]),
        .i_WrData   (bus.wrData[7:0]),
        .i_WrEnable (bus.wrEnable));

    RwMemory #(
        .DATA_WIDTH (DATA_WIDTH),
        .ADDR_WIDTH (ADDR_WIDTH-2))
    memoryB1 (
        .i_Clock    (i_clock),
        .i_Addr     (wordAddr),
        .o_RdAddr   (bus.rdData[15:8]),
        .i_WrData   (bus.wrData[15:8]),
        .i_WrEnable (bus.wrEnable));

    RwMemoryB2 #(
        .DATA_WIDTH (DATA_WIDTH),
        .ADDR_WIDTH (ADDR_WIDTH-2))
    memory (
        .i_Clock    (i_clock), 
        .i_Addr     (wordAddr),
        .o_RdAddr   (bus.rdData[23:16]),
        .i_WrData   (bus.wrData[23:16]),
        .i_WrEnable (bus.wrEnable));

    RwMemory #(
        .DATA_WIDTH (DATA_WIDTH),
        .ADDR_WIDTH (ADDR_WIDTH-2))
    memoryB3 (
        .i_Clock    (i_clock),
        .i_Addr     (bus.addr[ADDR_WIDTH:2]),
        .o_RdAddr   (bus.rdData[31:24]),
        .i_WrData   (bus.wrData[31:24]),
        .i_WrEnable (bus.wrEnable));

endmodule