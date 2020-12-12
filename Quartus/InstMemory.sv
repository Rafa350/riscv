module InstMemory
#(
    parameter PC_WIDTH = 32)
(   
    InstMemoryBus.Slave IBus);

    localparam SIZE = 35;
        
    logic [31:0] Data[0:SIZE-1];
           
    always_comb 
        IBus.Inst = Data[IBus.Addr];

    initial
        $readmemh("../build/Firmware/main.txt", Data);

endmodule