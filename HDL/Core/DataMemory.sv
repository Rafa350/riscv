module DataMemory
#(
    parameter DATA_WIDTH = 32;
    parameter ADDR_WIDTH = 32)
(   
    input logic         i_Clock,
    DataMemoryBus.Slave bus);

    RwMemory #(
        .DATA_WIDTH (DATA_WIDTH),
        .ADDR_WIDTH (ADDR_WIDTH))
    memory (
        .i_Clock    (i_Clock),
        .i_Addr     (bus.Addr),
        .o_RdAddr   (bus.RdData),
        .i_WrData   (bus.WrData),
        .i_WrEnable (bus.WrEnable));

endmodule