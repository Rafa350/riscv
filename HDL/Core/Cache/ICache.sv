module ICache
    import Config::*, Types::*;
#(
    parameter SETS     = 1,    // Nombre de vias
    parameter BLOCKS   = 4,    // Nombre de blocs
    parameter ELEMENTS = 128)  // Nombre de linies
(
    // Senyals de control
    input  logic    i_clock,     // Senyal de rellotge
    input  logic    i_reset,     // Senyal de reset

    // Interficie amb la cpu
    input  InstAddr i_addr,      // Adressa en words de la instruccio
    input  logic    i_rd,        // Autoritza lectura
    output Inst     o_inst,      // Instruccio trobada
    output logic    o_busy,      // Indica ocupat
    output logic    o_hit,       // Indica instruccio disponible

    // Interficie amb la memoria
    output InstAddr o_mem_addr,  // Adresa de la memoria principal en words
    input  Inst     i_mem_data); // Dades recuperades de la memoria principal


    localparam DATALINE_WIDTH = $size(Inst) * BLOCKS;
    localparam BLOCK_WIDTH    = $clog2(BLOCKS);
    localparam INDEX_WIDTH    = $clog2(ELEMENTS);
    localparam TAG_WIDTH      = $size(InstAddr) - 2 - INDEX_WIDTH - BLOCK_WIDTH;


    typedef logic [BLOCK_WIDTH-1:0] Block;
    typedef logic [INDEX_WIDTH-1:0] Index;
    typedef logic [TAG_WIDTH-1:0]   Tag;


    Block block; // Bloc de dades
    Index index; // Index del cache
    Tag   tag;   // Tag del cache


    // Separa els components de l'adressa.
    //
    assign tag   = i_addr[2+BLOCK_WIDTH+INDEX_WIDTH+:TAG_WIDTH];
    assign index = i_addr[2+BLOCK_WIDTH+:INDEX_WIDTH];
    assign block = i_addr[2+:BLOCK_WIDTH];

    // Asignacio de les sortides
    //
    assign o_mem_addr = {cacheCtrl_tag, cacheCtrl_index, cacheCtrl_block, 2'b00};
    assign o_busy     = cacheCtrl_busy;
    assign o_hit      = cacheCtrl_hit & i_rd;


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
        .TAG_WIDTH   (TAG_WIDTH),
        .INDEX_WIDTH (INDEX_WIDTH),
        .BLOCK_WIDTH (BLOCK_WIDTH))
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

    logic                      cacheSet_hit;
    logic [DATALINE_WIDTH-1:0] cacheSet_data;
    Inst                       data0, data1, data2;

    CacheSet #(
        .DATA_WIDTH  (DATALINE_WIDTH),
        .TAG_WIDTH   (TAG_WIDTH),
        .INDEX_WIDTH (INDEX_WIDTH),
        .BLOCKS      (BLOCKS))
    cacheSet (
        .i_clock (i_clock),
        .i_reset (i_reset),
        .i_we    (cacheCtrl_wr & (cacheCtrl_block == 2'b11)),
        .i_cl    (cacheCtrl_cl),
        .i_tag   (cacheCtrl_tag),
        .i_index (cacheCtrl_index),
        .i_wdata ({i_mem_data, data2, data1, data0}),
        .o_rdata (cacheSet_data),
        .o_hit   (cacheSet_hit));

    // Registra les lectures parcials dels blocs fins a completar
    // una linia
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
        .WIDTH (DATA_WIDTH))
    mux (
        .i_select (cacheCtrl_block),
        .i_input0 (cacheSet_data[0+:32]),
        .i_input1 (cacheSet_data[32+:32]),
        .i_input2 (cacheSet_data[64+:32]),
        .i_input3 (cacheSet_data[96+:32]),
        .o_output (o_inst));


endmodule
