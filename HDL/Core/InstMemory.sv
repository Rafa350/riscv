module InstMemory
    import Types::*;
#(
    parameter FILE_NAME = "firmware.txt")
(
    InstMemoryBus.slave bus);

    localparam DATA_WIDTH = $size(Inst);
    localparam ADDR_WIDTH = $size(InstAddr);

    RoMemory #(
        .DATA_WIDTH (DATA_WIDTH),
        .ADDR_WIDTH (ADDR_WIDTH),
        .FILE_NAME  (FILE_NAME))
    memory (
        .i_addr   (bus.addr),
        .o_rdData (bus.inst));

endmodule
