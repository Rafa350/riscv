module DataL1Cache
    import Config::*, Types::*;
(
    input logic    i_clock,  // Colck
    input logic    i_reset,  // Reset
    DataBus.master bus,      // Bus de dades cap a la cache L2 o a la memoria principal
    DataBus.slave  coreBus); // Bus de dades de la CPU

    logic cache_busy;
    logic cache_hit;

    DCache
    cache(
        .i_clock     (i_clock),
        .i_reset     (i_reset),

        .o_mem_addr  (bus.addr),
        .o_mem_we    (bus.we),
        .o_mem_re    (bus.re),
        .o_mem_be    (bus.wb),
        .o_mem_wdata (bus.wdata),
        .i_mem_rdata (bus.rdata),

        .i_addr      (coreBus.addr),
        .i_re        (coreBus.re),
        .i_we        (coreBus.we),
        .i_be        (coreBus.wb),
        .o_rdata     (coreBus.rdata),
        .i_wdata     (coreBus.wdata),
        .o_busy      (cache_busy),
        .o_hit       (cache_hit));

    assign coreBus.busy = cache_busy | ~cache_hit;

endmodule
