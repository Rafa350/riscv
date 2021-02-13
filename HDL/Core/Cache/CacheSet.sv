// -----------------------------------------------------------------------
//
//       Cache de lectura
//
//       Parametres:
//            DATA_WIDTH   : Amplada en bits de les dades
//            TAG_WIDTH    : Amplada en bits del tag
//            INDEX_WIDTH  : Amplada en bits del index del bloc
//            OFFSET_WIDTH : Amplada en bits del offset dins del bloc
//
//       Entrada:
//            i_clock   : Senyal de rellotge
//            i_reset   : Senyal de reset
//            i_write   : Habilita l'escriptura
//            l_clear   : Habilita la neteja
//            i_tag     : Tag
//            i_index   : Adressa
//            i_wdata   : Dades per escriure
//
//       Sortides:
//            o_rdata   : Dades lleigides
//            o_hit     : Coincidencia
//
// -----------------------------------------------------------------------

module CacheSet
#(
    parameter DATA_WIDTH   = 32, // Amplada de dades en bits
    parameter TAG_WIDTH    = 8,  // Amplada del tag en bits
    parameter INDEX_WIDTH  = 5,  // Amplada del index en bits
    parameter OFFSET_WIDTH = 2)  // Amplada del offset dins del bloc en bits
(
    input  logic                    i_clock,  // Clock
    input  logic                    i_reset,  // Reset
    input  logic                    i_write,  // Habilita escriptura en un bloc
    input  logic                    i_clear,  // Habilita neteja en un bloc
    input  logic [TAG_WIDTH-1:0]    i_tag,    // Tag
    input  logic [INDEX_WIDTH-1:0]  i_index,  // Index del bloc
    input  logic [OFFSET_WIDTH-1:0] i_offset, // Offset d'ins del bloc
    input  logic [DATA_WIDTH-1:0]   i_wdata,  // Dades per escriure
    output logic [DATA_WIDTH-1:0]   o_rdata,  // Dades lleigides
    output logic                    o_hit);   // Indica coincidencia i dades recuperades

    localparam BLOCK_SIZE = 2**OFFSET_WIDTH; // Tamany del bloc

    typedef logic [TAG_WIDTH-1:0]  Tag;       // Tag
    typedef logic [DATA_WIDTH-1:0] CacheData; // Dades
    typedef struct packed { // Metadades
        logic valid;        // -Indicador d'entrada valida
        Tag   tag;          // -Tag de la entrada
    } CacheMeta;


    CacheData md_rdata; // Dades per escriure en memoria de dades
    CacheData md_wdata; // Dades lleigides de la memoria de dades
    logic     md_we;    // Habilita escriptura en la memoria de dades
    CacheMeta mm_rdata; // Dades per escriure en la memoria de metadades
    CacheMeta mm_wdata; // Dades lleigides en la m,emoria de metadades
    logic     mm_we;    // Habilita la escriptura en la memoria de metadades


    // Control de la memoria de dades
    //
    assign md_we    = i_write & ~i_clear;
    assign md_wdata = i_wdata;
    assign o_rdata  = md_rdata;

    // Control de la memoria de metadades
    //
    assign mm_we          = i_write | i_clear;
    assign mm_wdata.valid = i_clear ? 1'b0 : 1'b1;
    assign mm_wdata.tag   = i_clear ? Tag'(0) : i_tag;
    assign o_hit          = (mm_rdata.tag == i_tag) & mm_rdata.valid & ~i_reset & ~i_clear & ~i_write;


    // -------------------------------------------------------------------
    // Memoria de dades
    // -------------------------------------------------------------------

    CacheMem #(
        .DATA_WIDTH ($size(CacheData)),
        .ADDR_WIDTH (INDEX_WIDTH+OFFSET_WIDTH))
    dataMem (
        .i_clock (i_clock),
        .i_we    (md_we),
        .i_addr  ({i_index, i_offset}),
        .i_wdata (md_wdata),
        .o_rdata (md_rdata));


    // ------------------------------------------------------------------
    // Memoria de metadades
    // ------------------------------------------------------------------

    CacheMem #(
        .DATA_WIDTH ($size(CacheMeta)),
        .ADDR_WIDTH (INDEX_WIDTH))
    metaMem (
        .i_clock (i_clock),
        .i_we    (mm_we),
        .i_addr  (i_index),
        .i_wdata (mm_wdata),
        .o_rdata (mm_rdata));


endmodule