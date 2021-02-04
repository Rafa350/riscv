module DataL1Cache
    import Types::*;
(
    input logic    i_clock,
    input logic    i_reset,
    DataBus.master cacheBus,  // Bus de dades cap a la cache L2 o a la memoria principal
    DataBus.slave  localBus); // Bus de dades de la CPU


    logic cache_busy;
    logic cache_hit;

    DCache
    cache(
        .i_clock     (i_clock),
        .i_reset     (i_reset),

        .o_mem_addr  (cacheBus.addr),
        .o_mem_we    (cacheBus.we),
        .o_mem_re    (cacheBus.re),
        .o_mem_wdata (cacheBus.wdata),
        .i_mem_rdata (cacheBus.rdata),

        .i_addr      (localBus.addr),
        .i_re        (localBus.re),
        .i_we        (localBus.we),
        .o_rdata     (localBus.rdata),
        .i_wdata     (localBus.wdata),
        .o_busy      (cache_busy),
        .o_hit       (cache_hit));

    assign localBus.busy = cache_busy | ~cache_hit;

endmodule
