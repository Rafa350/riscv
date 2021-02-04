module L2Cache
    import Types::*;
(
    input              logic  i_clock,
    input              logic  i_reset,

    InstCacheBus.slave instCacheBus,
    DataCacheBus.slave dataCacheBus);

endmodule
