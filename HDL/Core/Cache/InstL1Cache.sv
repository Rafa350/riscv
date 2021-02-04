module InstL1Cache
    import Config::*, Types::*;
(
    input logic         i_clock,   // Clock
    input logic         i_reset,   // Reset
    InstCacheBus.master cacheBus,  // Bus d'instruccions cap el cache L2 o la RAM principal
    InstBus.slave       localBus); // Bus d'instruccions de la CPU


    logic cache_busy;
    logic cache_hit;


    ICache #(
        .SETS        (1),                  // Nombre de vias
        .BLOCKS      (RV_ICACHE_BLOCKS),   // Nombre de blocs per linia
        .ELEMENTS    (RV_ICACHE_ELEMENTS)) // Nombre de linies
    cache (
        .i_clock    (i_clock),
        .i_reset    (i_reset),

        .o_mem_addr (cacheBus.addr),
        .i_mem_data (cacheBus.inst[0]),

        .i_addr     (localBus.addr),
        .i_rd       (localBus.re),
        .o_inst     (localBus.inst),
        .o_busy     (cache_busy),
        .o_hit      (cache_hit));

    assign localBus.busy = cache_busy | ~cache_hit;

endmodule
