module InstMemory
#(  
    parameter PC_WIDTH  = 32,
    parameter FILE_NAME = "firmware.txt")
(
    InstMemoryBus.Slave IBus);
    
    RoMemory #(
        .DATA_WIDTH (32),
        .ADDR_WIDTH (PC_WIDTH),
        .FILE_NAME  (FILE_NAME))
    memory (
        .i_Addr   (IBus.Addr),
        .o_RdData (IBus.Inst));

endmodule
