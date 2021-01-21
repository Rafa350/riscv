`include "RV.svh"


module InstL1Cache
    import Types::*;
(
    input logic          i_clock,
    input logic          i_reset,
    InstMemoryBus.slave  cacheBus,
    InstMemoryBus.master memBus);

    assign memBus.addr   = cacheBus.addr;
    assign memBus.rd     = cacheBus.rd;
    assign cacheBus.inst = memBus.inst;
    assign cacheBus.busy = memBus.busy;

endmodule
