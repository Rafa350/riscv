module InstMemory
    import Types::*;
#(
    parameter FILE_NAME = "firmware.txt")
(
    InstMemoryBus.slave bus);


    RoMemory #(
        .DATA_WIDTH ($size(Inst)),
        .ADDR_WIDTH ($size(InstAddr)),
        .FILE_NAME  (FILE_NAME))
    memory (
        .i_addr (bus.addr),
        .o_data (bus.inst));

endmodule
