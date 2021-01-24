module ICache
    import Config::*;
    import Types::*;
(
    input  logic    i_clock,     // Senyal de rellotge
    input  logic    i_reset,     // Senyal de reset

    input  InstAddr i_addr,      // Adressa en bytes de la instruccio (Aliniat a 32 bits)
    input  logic    i_rd,        // Autoritza lectura
    output Inst     o_inst,      // Instruccio trobada
    output logic    o_busy,      // Indica ocupat
    output logic    o_hit,       // Indica instruccio disponible

    output InstAddr o_mem_addr,  // Adresa de la memoria principal en words
    input  Inst     i_mem_data); // Dades recuperades de la memoria principal


    localparam CACHE_DATA_WIDTH     = $size(Inst);
    localparam CACHE_DATALINE_WIDTH = CACHE_DATA_WIDTH * RV_ICACHE_BLOCKS;
    localparam CACHE_ADDR_WIDTH     = $size(InstAddr) - 2;
    localparam BLOCK_WIDTH          = $clog2(RV_ICACHE_BLOCKS);
    localparam INDEX_WIDTH          = $clog2(RV_ICACHE_ELEMENTS);
    localparam TAG_WIDTH            = CACHE_ADDR_WIDTH - INDEX_WIDTH - BLOCK_WIDTH;


    typedef logic [BLOCK_WIDTH-1:0] Block;
    typedef logic [INDEX_WIDTH-1:0] Index;
    typedef logic [TAG_WIDTH-1:0]   Tag;

    logic [CACHE_ADDR_WIDTH-1:0] addr;  // Adresa en words
    Block                        block; // Bloc de dades
    Index                        index; // Index del cache
    Tag                          tag;   // Tag del cache


    // Separa els componentds de l'adressa.
    // Cal conmvertir l'adressa en byres a words.
    //
    assign addr  = i_addr[$size(i_addr)-1:2]; // Conversio
    assign tag   = addr[TAG_WIDTH+INDEX_WIDTH+BLOCK_WIDTH-1:INDEX_WIDTH+BLOCK_WIDTH];
    assign index = addr[INDEX_WIDTH+BLOCK_WIDTH-1:BLOCK_WIDTH];
    assign block = addr[BLOCK_WIDTH-1:0];

    // Asignacio de les sortides
    // S'ha de convertir l'adressa de words a bytes
    //
    assign o_mem_addr = {cacheCtrl_tag, cacheCtrl_index, cacheCtrl_block, 2'b00}; // Conversio
    assign o_busy = cacheCtrl_busy;
    assign o_hit  = cacheCtrl_hit & i_rd;


    // -------------------------------------------------------------------
    // Cache controller
    // -------------------------------------------------------------------

    logic cacheCtrl_cl;
    logic cacheCtrl_wr;
    logic cacheCtrl_hit;
    logic cacheCtrl_busy;
    Tag   cacheCtrl_tag;
    Index cacheCtrl_index;
    Block cacheCtrl_block;

    CacheController #(
        .TAG_WIDTH   ($size(Tag)),
        .INDEX_WIDTH ($size(Index)),
        .BLOCK_WIDTH ($size(Block)))
    cacheCtrl (
        .i_clock (i_clock),
        .i_reset (i_reset),
        .i_tag   (tag),
        .i_index (index),
        .i_block (block),
        .i_hit   (cacheSet_hit),
        .i_rd    (i_rd),
        .o_tag   (cacheCtrl_tag),
        .o_index (cacheCtrl_index),
        .o_block (cacheCtrl_block),
        .o_cl    (cacheCtrl_cl),
        .o_wr    (cacheCtrl_wr),
        .o_hit   (cacheCtrl_hit),
        .o_busy  (cacheCtrl_busy));


    // -------------------------------------------------------------------
    // Cache sets
    // -------------------------------------------------------------------

    logic cacheSet_hit;
    logic [CACHE_DATALINE_WIDTH-1:0] cacheSet_data;
    logic [CACHE_DATA_WIDTH-1:0] data0, data1, data2;

    CacheSet #(
        .DATA_WIDTH  (CACHE_DATALINE_WIDTH),
        .TAG_WIDTH   ($size(Tag)),
        .INDEX_WIDTH ($size(Index)))
    cacheSet (
        .i_clock (i_clock),
        .i_reset (i_reset),
        .i_wr    (cacheCtrl_wr & (cacheCtrl_block == 2'b11)),
        .i_cl    (cacheCtrl_cl),
        .i_tag   (cacheCtrl_tag),
        .i_index (cacheCtrl_index),
        .i_data  ({i_mem_data, data2, data1, data0}),
        .o_data  (cacheSet_data),
        .o_hit   (cacheSet_hit));

    // Registre les lectures parcials dels blocs
    //
    always_ff @(posedge i_clock)
        if (cacheCtrl_wr)
            unique case (cacheCtrl_block)
                2'b00: data0 <= i_mem_data;
                2'b01: data1 <= i_mem_data;
                2'b10: data2 <= i_mem_data;
                2'b11: ;
            endcase


    // -------------------------------------------------------------------
    // Evalua el bloc per lleigir
    // -------------------------------------------------------------------

    Mux4To1 #(
        .WIDTH ($size(Inst)))
    mux (
        .i_select (cacheCtrl_block),
        .i_input0 (cacheSet_data[31:0]),
        .i_input1 (cacheSet_data[63:32]),
        .i_input2 (cacheSet_data[95:64]),
        .i_input3 (cacheSet_data[127:96]),
        .o_output (o_inst));


endmodule
