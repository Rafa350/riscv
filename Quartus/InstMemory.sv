module InstMemory
    import Types::*;
(
    InstBus.slave bus);


    localparam SIZE = 99;


    Inst data[0:SIZE-1];


    assign bus.inst = data[bus.addr[$size(bus.addr)-1:2]];
    assign bus.busy = 1'b0;


    initial
        $readmemh("../build/Firmware/firmware.txt", data);

endmodule