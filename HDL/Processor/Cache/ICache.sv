module ICache
    import
        Config::*,
        ProcessorDefs::*,
        CacheDefs::*;
(
    // Senyals de control
    input  logic    i_clock,      // Senyal de rellotge
    input  logic    i_reset,      // Senyal de reset

    // Interficie amb la cpu
    input  InstAddr i_addr,       // Adressa de la instruccio
    input  logic    i_re,         // Habilita la lectura
    output Inst     o_inst,       // Instruccio trobada
    output logic    o_busy,       // Indica ocupat
    output logic    o_hit,        // Indica instruccio disponible

    // Interficie amb la memoria
    output InstAddr o_mem_addr,   // Adressa de la memoria principal
    output logic    o_mem_re,     // Habilita la lectura
    input  logic    i_mem_busy,   // Indica memoria ocupada
    input  Inst     i_mem_rdata); // Dades recuperades de la memoria principal


    ICacheTag    tag;   // Tag del cache
    ICacheIndex  index; // Index del cache
    ICacheOffset offset; // Bloc de dades


    // Separa els components de l'adressa. La converteix a direccionament en words
    //
    assign tag    = i_addr[2+ICACHE_OFFSET_WIDTH+ICACHE_INDEX_WIDTH+:ICACHE_TAG_WIDTH];
    assign index  = i_addr[2+ICACHE_OFFSET_WIDTH+:ICACHE_INDEX_WIDTH];
    assign offset = i_addr[2+:ICACHE_OFFSET_WIDTH];

    // Senyals de la memoria principal o L2
    //
    assign o_mem_addr = {cacheCtrl_tag, cacheCtrl_index, cacheCtrl_offset, 2'b00};
    assign o_mem_re   = cacheCtrl_memRead;

    // Senyals de control
    //
    assign o_busy = cacheCtrl_busy & i_re;
    assign o_hit  = cacheCtrl_hit & i_re;


    // -------------------------------------------------------------------
    // Cache controller
    // -------------------------------------------------------------------

    logic        cacheCtrl_cacheClear;
    logic        cacheCtrl_cacheWrite;
    logic        cacheCtrl_memRead;
    logic        cacheCtrl_hit;
    logic        cacheCtrl_busy;
    ICacheTag    cacheCtrl_tag;
    ICacheIndex  cacheCtrl_index;
    ICacheOffset cacheCtrl_offset;

    ICacheController #(
        .TAG_WIDTH    ($size(ICacheTag)),
        .INDEX_WIDTH  ($size(ICacheIndex)),
        .OFFSET_WIDTH ($size(ICacheOffset)))
    cacheCtrl (
        .i_clock      (i_clock),
        .i_reset      (i_reset),
        .i_tag        (tag),
        .i_index      (index),
        .i_offset     (offset),
        .i_hit        (cacheSet_hit),
        .i_re         (i_re),
        .o_tag        (cacheCtrl_tag),
        .o_index      (cacheCtrl_index),
        .o_offset     (cacheCtrl_offset),
        .o_cacheClear (cacheCtrl_cacheClear),
        .o_cacheWrite (cacheCtrl_cacheWrite),
        .o_memRead    (cacheCtrl_memRead),
        .o_hit        (cacheCtrl_hit),
        .o_busy       (cacheCtrl_busy));


    // -------------------------------------------------------------------
    // Cache sets
    // -------------------------------------------------------------------

    logic cacheSet_hit;

    CacheSet #(
        .DATA_WIDTH   ($size(Inst)),
        .TAG_WIDTH    ($size(ICacheTag)),
        .INDEX_WIDTH  ($size(ICacheIndex)),
        .OFFSET_WIDTH ($size(ICacheOffset)))
    cacheSet (
        .i_clock  (i_clock),
        .i_reset  (i_reset),
        .i_write  (cacheCtrl_cacheWrite),
        .i_clear  (cacheCtrl_cacheClear),
        .i_tag    (cacheCtrl_tag),
        .i_index  (cacheCtrl_index),
        .i_offset (cacheCtrl_offset),
        .i_wdata  (i_mem_rdata),
        .o_rdata  (o_inst),
        .o_hit    (cacheSet_hit));

endmodule
