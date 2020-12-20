module DataMemory
    import Types::*;
(
    input logic         i_clock,
    DataMemoryBus.slave bus);

    localparam DATA_WIDTH = $size(bus.data);
    localparam ADDR_WIDTH = $size(bus.addr);

    RwMemory #(
        .DATA_WIDTH (DATA_WIDTH),
        .ADDR_WIDTH (ADDR_WIDTH))
    memory (
        .i_Clock    (i_clock),
        .i_Addr     (bus.addr),
        .o_RdAddr   (bus.rdData),
        .i_WrData   (bus.wrData),
        .i_WrEnable (bus.wrEnable));

endmodule