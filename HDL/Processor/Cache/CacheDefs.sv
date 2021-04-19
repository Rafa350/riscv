package CacheDefs;

    import
        Config::*,
        ProcessorDefs::*;


    localparam int unsigned ICACHE_INDEX_WIDTH  = $clog2(RV_ICACHE_ELEMENTS);
    localparam int unsigned ICACHE_OFFSET_WIDTH = $clog2(RV_ICACHE_BLOCKS);
    localparam int unsigned ICACHE_TAG_WIDTH    = $size(InstAddr) - 2 - ICACHE_INDEX_WIDTH - ICACHE_OFFSET_WIDTH;


    typedef logic [ICACHE_TAG_WIDTH-1:0]    ICacheTag;
    typedef logic [ICACHE_INDEX_WIDTH-1:0]  ICacheIndex;
    typedef logic [ICACHE_OFFSET_WIDTH-1:0] ICacheOffset;


endpackage