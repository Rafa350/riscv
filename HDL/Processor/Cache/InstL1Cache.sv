module InstL1Cache
    import
        Config::*,
        ProcessorDefs::*;
(
    input logic    i_clock,  // Clock
    input logic    i_reset,  // Reset
    InstBus.master bus,      // Bus d'instruccions cap el cache L2 o la RAM principal
    InstBus.slave  coreBus); // Bus d'instruccions de la CPU


    logic cache_busy;
    logic cache_hit;

    ICache
    cache (
        .i_clock     (i_clock),
        .i_reset     (i_reset),

        .o_mem_addr  (bus.addr),
        .o_mem_re    (bus.re),
        .i_mem_busy  (bus.busy),
        .i_mem_rdata (bus.inst),

        .i_addr      (coreBus.addr),
        .i_re        (coreBus.re),
        .o_inst      (coreBus.inst),

        .o_busy      (cache_busy),
        .o_hit       (cache_hit));

    assign coreBus.busy = coreBus.re & (cache_busy | ~cache_hit);

endmodule
