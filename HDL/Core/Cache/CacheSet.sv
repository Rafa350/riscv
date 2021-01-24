// -----------------------------------------------------------------------
//
//       Cache de lectura
//
//       Parametres:
//            DATA_WIDTH  : Amplada en bits de les dades
//            TAG_WIDTH   : Amplada en bits del tag
//            INDEX_WIDTH : Amplada en bits de les d'adresses
//
//       Entrada:
//            i_clock   : Senyal de rellotge
//            i_reset   : Senyal de reset
//            i_index   : Adressa
//            i_wr      : Habilita l'excriptura
//            l_cl      : Habilita la neteja
//            i_tag     : Tag
//            i_data    : Dades
//
//       Sortides:
//            o_data    : Dades
//            o_hit     : Coincidencia
//
// -----------------------------------------------------------------------

module CacheSet
#(
    parameter DATA_WIDTH  = 32, // Amplada de dades en bits
    parameter TAG_WIDTH   = 3,  // Amplada del tag en bits
    parameter INDEX_WIDTH = 5)  // Amplada del index en bits
(
    input  logic                   i_clock, // Clock
    input  logic                   i_reset, // Reset
    input  logic                   i_wr,    // Habilita escriptura
    input  logic                   i_cl,    // Habilita invalidacio
    input  logic [INDEX_WIDTH-1:0] i_index, // Index
    input  logic [TAG_WIDTH-1:0]   i_tag,   // Tag
    input  logic [DATA_WIDTH-1:0]  i_data,  // Dades
    output logic [DATA_WIDTH-1:0]  o_data,  // Dades
    output logic                   o_hit);  // Indica coincidencia i dades recuperades


    typedef logic [TAG_WIDTH-1:0]  Tag;       // Tag
    typedef logic [DATA_WIDTH-1:0] CacheData; // Dades

    typedef struct packed { // Metadades
        logic valid;        // -Indicador d'entrada valida
        Tag   tag;          // -Tag de la entrada
    } CacheMeta;


    CacheData mem_rdData;  // Dades per escriure en memoria de dades
    CacheData mem_wrData;  // Dades lleigides de la memoria de dades
    logic     mem_wr;      // Habilita escriptura en la memoria de dades
    CacheMeta meta_rdData; // Dades per escriure en la memoria de metadades
    CacheMeta meta_wrData; // Dades lleigides en la m,emoria de metadades
    logic     meta_wr;     // Habilita la escriptura en la memoria de metadades


    // Control de la memoria de dades
    //
    assign mem_wr     = i_wr & ~i_cl;
    assign mem_wrData = i_data;
    assign o_data     = mem_rdData;

    // Control de la memoria de metadades
    //
    assign meta_wr           = i_wr | i_cl;
    assign meta_wrData.valid = i_cl ? 1'b0 : 1'b1;
    assign meta_wrData.tag   = i_cl ? Tag'(0) : i_tag;
    assign o_hit             = (meta_rdData.tag == i_tag) & meta_rdData.valid & ~i_reset & ~i_cl & ~i_wr;


    // -------------------------------------------------------------------
    // Memoria de dades
    // -------------------------------------------------------------------

    CacheMem #(
        .DATA_WIDTH ($size(CacheData)),
        .ADDR_WIDTH (INDEX_WIDTH))
    dataMem (
        .i_clock (i_clock),
        .i_wr    (mem_wr),
        .i_addr  (i_index),
        .i_data  (mem_wrData),
        .o_data  (mem_rdData));


    // ------------------------------------------------------------------
    // Memoria de metadades
    // ------------------------------------------------------------------

    CacheMem #(
        .DATA_WIDTH ($size(CacheMeta)),
        .ADDR_WIDTH (INDEX_WIDTH))
    metaMem (
        .i_clock (i_clock),
        .i_wr    (meta_wr),
        .i_addr  (i_index),
        .i_data  (meta_wrData),
        .o_data  (meta_rdData));


endmodule