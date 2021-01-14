module ICache
    import Types::*;
#(
    parameter INDEX_WIDTH = 5,
    parameter OFFSET_WIDTH = 4)
(
    input logic   i_clock,
    input logic   i_reset,
    
    DataAddr      i_addr,
    logic         i_rdEnable,
    Data          o_rdAddr);    
    
    localparam TAG_WIDTH = $sizeof(DataAddr) - INDEX_WIDTH - OFFSET_WIDTH;

    typedef logic [TAG_WIDTH-1:0]    Tag;
    typedef logic [OFFSET_WIDTH-1:0] Offset;
    
    typedef struct {
        Tag                    tag;
        logic                  valid;
        Data [2**OFFSET_WIDTH] data;
    } CacheEntry;
    
    Tag tag;
    Index  index;
    Offset offset;
    CascheEntry cacheEntries[2**INDEX_WIDTH];

    assign offset = i_addr[OFFSET_WIDTH-1:0];
    assign index  = i_addr[INDEX_WIDTH+OFFSET_WIDTH-1:OFFSET_WIDTH];
    assign tag    = i_addr[TAG_WIDTH+INDEX_WIRDT+OFFSERT_WIDTH-1:INDEX_WIDTH+OFFSET_WIDTH];

endmodule
