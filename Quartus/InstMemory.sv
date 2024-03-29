module InstMemory
    import 
        Config::*,
        ProcessorDefs::*;
(
    InstBus.slave bus);


    localparam SIZE = 129;


    Inst data[0:SIZE-1];


    assign bus.inst = data[bus.addr[$size(bus.addr)-1:2]];
    assign bus.busy = 1'b0;


    initial
        $readmemh("../Run/firmware.txt", data);

endmodule