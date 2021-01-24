module InstL1Cache
    import Types::*;
(
    input logic          i_clock,
    input logic          i_reset,
    InstMemoryBus.slave  cacheBus,
    InstMemoryBus.master memBus);

    logic cache_busy;
    logic cache_hit;

    ICache
    cache (
        .i_clock    (i_clock),
        .i_reset    (i_reset),
        .i_mem_data (memBus.inst),
        .o_mem_addr (memBus.addr),
        .i_addr     (cacheBus.addr),
        .i_rd       (cacheBus.rd),
        .o_inst     (cacheBus.inst),
        .o_busy     (cache_busy),
        .o_hit      (cache_hit));

    assign cacheBus.busy = cache_busy | ~cache_hit;

endmodule
