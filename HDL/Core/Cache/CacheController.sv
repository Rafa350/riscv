// -----------------------------------------------------------------------
//
//       Controlador de memoria cache de lectura
//
//       Parametres:
//            TAG_WIDTH      : Amplada del tag en bits
//            INDEX_WIDTH    : Amplada del index en bits
//            BLOCK_WIDTH    : Amplada del bloc en bits
//
//       Entrades:
//            i_clock        : Senyal de rellotge
//            i_reset        : Senyal de reset
//            i_hit          : Indicador de coincidencia del cache
//            i_rd           : Solicitit de lectura
//            i_tag          : El tag
//            i_index        : El index
//            i_block        : El bloc
//
//       Sortides:
//            o_tag          : El tag
//            o_index        : El index
//            o_block        : El bloc
//            o_wr           : Habilita escriptura en el cache
//            o_cl           : Habilita inicialitzacio del cache
//            o_hit          : Indica coincidencia
//            o_busy         : Indica ocupat. O be per inicialitzacio
//                             o per escriptura en cache
//
//       Notes:
//            En cas d'activacio de 'i_reset', s'inicia el proces
//            d'inicialitzacio de la cache, es posa 'o_cl' en 1,
//            i 'o_busy' en 1, durant els cicles necesaris per la
//            inicialitzacio del cache. En cada cicle 'o_index' indica
//            la linia de cache que cal inicialitzar. Un cop finalitzat
//            el process, 'o_cl' passa a 0, 'o_busy' passa a 0,
//            i 'o_index' s'assigna al valor de 'i_index'.
//            En cas d'activar 'i_rd', si hi ha coincidentia, perque aixi
//            ho indica la entrada 'i_hit', el senyal 'o_hit' passa a 1.
//            Si 'i_hit' es 0, es a dir, no hi ha coincidencia, s'inicia
//            el proces de lectura de la memoria, aleshores 'o_tag',
//            'o_index' i 'o_block', indican l'adressa de memoria a
//            lleigit, i 'o_wr' indica que cal escriure el bloc en el
//            cache en l'ultim cicle de lectura del bloc.
//
// -----------------------------------------------------------------------

module CacheController
#(
    parameter TAG_WIDTH   = 3, // Amplada del tag en bits
    parameter INDEX_WIDTH = 5, // Amplada del index en bits
    parameter BLOCK_WIDTH = 2) // Amplada del block en bits
(
    input  logic                   i_clock, // Clock
    input  logic                   i_reset, // Reset
    input  logic                   i_hit,   // Indica coincidencia
    input  logic                   i_rd,    // Solicita lectura
    input  logic [TAG_WIDTH-1:0]   i_tag,   // Tag
    input  logic [INDEX_WIDTH-1:0] i_index, // Index
    input  logic [BLOCK_WIDTH-1:0] i_block, // Bloc
    output logic [TAG_WIDTH-1:0]   o_tag,   // Tag
    output logic [INDEX_WIDTH-1:0] o_index, // Index
    output logic [BLOCK_WIDTH-1:0] o_block, // Bloc
    output logic                   o_wr,    // Habilita escriptura en el cache
    output logic                   o_cl,    // Habilita neteja en el cache
    output logic                   o_hit,   // Indica coincidencia
    output logic                   o_busy); // Indica ocupat


    localparam CACHE_ELEMENTS = 2**INDEX_WIDTH;
    localparam CACHE_BLOCKS   = 2**BLOCK_WIDTH;


    typedef enum logic [1:0] { // Estats de la maquina
        State_INIT,            // -Inicialitzacio
        State_IDLE,            // -Obte dades de la cache
        State_READ             // -Actualitzacio del cache
    } State;

    typedef logic [TAG_WIDTH-1:0]   Tag;    // Tag
    typedef logic [INDEX_WIDTH-1:0] Index;  // Index del cache
    typedef logic [BLOCK_WIDTH-1:0] Block;  // Bloc de dades


    Tag   tag;        // Tag
    Tag   nextTag;    // Seguent valor de 'tag'
    Index index;      // Index del cache
    Index nextIndex;  // Seguent valor de 'index'
    Block block;      // Block del cache
    Block nextBlock;  // Seguent valor de 'block'
    State state;      // Estat de la maquina
    State nextState;  // Seguent valor de 'state'


    always_comb begin

        o_index = i_index;
        o_block = i_block;
        o_tag   = i_tag;
        o_wr    = 1'b0;
        o_cl    = 1'b0;
        o_hit   = 1'b0;
        o_busy  = 1'b1;

        nextState = state;
        nextTag   = Tag'(0);
        nextIndex = Index'(0);
        nextBlock = Block'(0);

        unique case (state)
            State_INIT:
                begin
                    o_index = index;
                    o_cl = 1'b1;
                    nextIndex = index + 1;
                    if (Index'(index) == Index'(CACHE_ELEMENTS-1))
                        nextState = State_IDLE;
                end

            State_IDLE:
                begin
                    o_hit  = i_hit;
                    o_busy = 1'b0;
                    if (~i_hit & i_rd) begin
                        nextTag   = i_tag;
                        nextIndex = i_index;
                        nextBlock = Block'(0);
                        nextState = State_READ;
                    end
                end

            State_READ:
                begin
                    o_tag     = tag;
                    o_index   = index;
                    o_block   = block;
                    o_wr      = 1'b1;
                    nextTag   = tag;
                    nextIndex = index;
                    nextBlock = block + 1;
                    if (Block'(block) == Block'(CACHE_BLOCKS-1))
                        nextState = State_IDLE;
                end

            default:
                begin
                end

        endcase
    end

    always_ff @(posedge i_clock)
        if (i_reset) begin
            tag   <= Tag'(0);
            index <= Index'(0);
            block <= Block'(0);
            state <= State_INIT;
        end
        else begin
            tag   <= nextTag;
            index <= nextIndex;
            block <= nextBlock;
            state <= nextState;
        end


endmodule