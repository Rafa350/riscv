module DCache
    import Types::*;
#(
    parameter int unsigned SETS       = 1,   // Nombre de vias
    parameter int unsigned CACHE_SIZE = 128, // Tamany del cache
    parameter int unsigned BLOCK_SIZE = 4)   // Tamany del bloc
(
    // Senyals de control
    input  logic     i_clock,      // Clock
    input  logic     i_reset,      // Reset

    // Interficie amb la cpu
    input  DataAddr  i_addr,       // Adressa
    input  logic     i_we,         // Habilita escriptura
    input  logic     i_re,         // Habilita lectura
    input  ByteMask  i_be,         // Habilita bytes per escriure
    input  Data      i_wdata,      // Dades per escriure
    output Data      o_rdata,      // Dades lleigides
    output logic     o_busy,       // Indica ocupat
    output logic     o_hit,        // Indica coincidencia

    // Interficie amb la memoria
    output DataAddr  o_mem_addr,   // Adressa
    output logic     o_mem_we,     // Habilita escriptura
    output logic     o_mem_re,     // Habilita lectura
    output ByteMask  o_mem_be,     // Habilita bytes per escriure
    output Data      o_mem_wdata,  // Dades per escriure
    input  Data      i_mem_rdata); // Dades lleigides

    localparam INDEX_WIDTH  = $clog2(CACHE_SIZE);
    localparam OFFSET_WIDTH = $clog2(BLOCK_SIZE);
    localparam TAG_WIDTH    = $size(DataAddr) - 2 - INDEX_WIDTH - OFFSET_WIDTH;

    typedef logic [TAG_WIDTH-1:0]    Tag;
    typedef logic [INDEX_WIDTH-1:0]  Index;
    typedef logic [OFFSET_WIDTH-1:0] Offset;


    Tag    tag;   // Tag del cache
    Index  index; // Index del cache
    Offset offset; // Bloc de dades


    // Separa els components de l'adressa. La converteix a direccionament en words
    //
    assign tag    = i_addr[2+OFFSET_WIDTH+INDEX_WIDTH+:TAG_WIDTH];
    assign index  = i_addr[2+OFFSET_WIDTH+:INDEX_WIDTH];
    assign offset = i_addr[2+:OFFSET_WIDTH];

    // Senyals de la memoria principal o L2
    //
    assign o_mem_addr  = {cacheCtrl_tag, cacheCtrl_index, cacheCtrl_offset, 2'b00};
    assign o_mem_wdata = i_wdata;
    assign o_mem_re    = cacheCtrl_memRead;
    assign o_mem_we    = cacheCtrl_memWrite;
    assign o_mem_be    = i_be;

    // Senyals de control
    //
    assign o_busy = cacheCtrl_busy & (i_re | i_we);
    assign o_hit  = cacheCtrl_hit & i_re;


    // -------------------------------------------------------------------
    // Cache controller
    // -------------------------------------------------------------------

    logic  cacheCtrl_cacheClear;
    logic  cacheCtrl_cacheWrite;
    logic  cacheCtrl_memWrite;
    logic  cacheCtrl_memRead;
    logic  cacheCtrl_hit;
    logic  cacheCtrl_busy;
    Tag    cacheCtrl_tag;
    Index  cacheCtrl_index;
    Offset cacheCtrl_offset;

    DCacheController #(
        .TAG_WIDTH    ($size(Tag)),
        .INDEX_WIDTH  ($size(Index)),
        .OFFSET_WIDTH ($size(Offset)))
    cacheCtrl (
        .i_clock      (i_clock),
        .i_reset      (i_reset),
        .i_tag        (tag),
        .i_index      (index),
        .i_offset     (offset),
        .i_hit        (cacheSet_hit),
        .i_re         (i_re),
        .i_we         (i_we),
        .o_tag        (cacheCtrl_tag),
        .o_index      (cacheCtrl_index),
        .o_offset     (cacheCtrl_offset),
        .o_cacheClear (cacheCtrl_cacheClear),
        .o_cacheWrite (cacheCtrl_cacheWrite),
        .o_memRead    (cacheCtrl_memRead),
        .o_memWrite   (cacheCtrl_memWrite),
        .o_hit        (cacheCtrl_hit),
        .o_busy       (cacheCtrl_busy));


    // -------------------------------------------------------------------
    // Cache sets
    // -------------------------------------------------------------------

    logic cacheSet_hit;

    CacheSet #(
        .DATA_WIDTH   ($size(Inst)),
        .TAG_WIDTH    ($size(Tag)),
        .INDEX_WIDTH  ($size(Index)),
        .OFFSET_WIDTH ($size(Offset)))
    cacheSet (
        .i_clock  (i_clock),
        .i_reset  (i_reset),
        .i_write  (cacheCtrl_cacheWrite),
        .i_clear  (cacheCtrl_cacheClear),
        .i_tag    (cacheCtrl_tag),
        .i_index  (cacheCtrl_index),
        .i_offset (cacheCtrl_offset),
        .i_wdata  (i_mem_rdata),
        .o_rdata  (o_rdata),
        .o_hit    (cacheSet_hit));

endmodule