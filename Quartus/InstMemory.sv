module InstMemory
    import Types::*;
(
    InstMemoryBus.slave bus);

    localparam SIZE = 16;

    Inst data[0:SIZE-1];

    always_comb
        bus.inst = data[bus.addr[$size(bus.addr)-1:2]];

    initial
        $readmemh("../build/Firmware/firmware.txt", data);

endmodule