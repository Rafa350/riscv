module InstMemory
#(
    parameter PC_WIDTH = 32)
(
    InstMemoryBus.slave bus);

    localparam SIZE = 35;

    logic [31:0] data[0:SIZE-1];

    always_comb
        bus.inst = data[bus.addr[PC_WIDTH-1:2]];

    initial
        $readmemh("../build/Firmware/firmware.txt", data);

endmodule