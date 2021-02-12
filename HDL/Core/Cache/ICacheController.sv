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
//            i_rd           : Solicitut de lectura
//            i_tag          : El tag
//            i_index        : El index
//            i_block        : El bloc
//
//       Sortides:
//            o_tag          : El tag
//            o_index        : El index
//            o_block        : El bloc
//            o_write        : Habilita escriptura en el cache
//            o_clear        : Habilita inicialitzacio del cache
//            o_hit          : Indica coincidencia
//            o_busy         : Indica ocupat. O be per inicialitzacio
//                             o per escriptura en cache
//
//       Notes:
//            En cas d'activacio de 'i_reset', s'inicia el proces
//            d'inicialitzacio de la cache, es posa 'o_clear' en 1,
//            i 'o_busy' en 1, durant els cicles necesaris per la
//            inicialitzacio del cache. En cada cicle 'o_index' indica
//            la linia de cache que cal inicialitzar. Un cop finalitzat
//            el process, 'o_clear' passa a 0, 'o_busy' passa a 0,
//            i 'o_index' s'assigna al valor de 'i_index'.
//            En cas d'activar 'i_rd', si hi ha coincidentia, perque aixi
//            ho indica la entrada 'i_hit', el senyal 'o_hit' passa a 1.
//            Si 'i_hit' es 0, es a dir, no hi ha coincidencia, s'inicia
//            el proces de lectura de la memoria, aleshores 'o_tag',
//            'o_index' i 'o_block', indican l'adressa de memoria a
//            lleigit, i 'o_write' indica que cal escriure el bloc en el
//            cache en l'ultim cicle de lectura del bloc.
//
// -----------------------------------------------------------------------

module ICacheController
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
    output logic                   o_write, // Habilita escriptura en el cache
    output logic                   o_clear, // Habilita neteja en el cache
    output logic                   o_hit,   // Indica coincidencia
    output logic                   o_busy); // Indica ocupat


    localparam ELEMENTS = 2**INDEX_WIDTH;
    localparam BLOCKS   = 2**BLOCK_WIDTH;


    typedef enum logic [1:0] { // Estats de la maquina
        State_RESET,           // -Reset inicial
        State_CLEAR,           // -Neteja del cache
        State_LOOKUP,          // -Consulta dades en la cache
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

        o_tag   = i_tag;
        o_index = i_index;
        o_block = i_block;
        o_write = 1'b0;
        o_clear = 1'b0;
        o_hit   = 1'b0;
        o_busy  = 1'b1;

        nextState = state;
        nextTag   = tag;
        nextIndex = index;
        nextBlock = block;

        // verilator lint_off CASEINCOMPLETE
        unique case (state)
            State_RESET: begin
                nextIndex = Index'(0);
                nextState = State_CLEAR;
            end

            State_CLEAR: begin
                o_index = index;
                o_clear = 1'b1;
                nextIndex = index + Index'(1);
                if (Index'(index) == Index'(ELEMENTS-1))
                    nextState = State_LOOKUP;
            end

            State_LOOKUP: begin
                o_hit  = i_hit;
                o_busy = 1'b0;
                if (~i_hit & i_rd) begin
                    nextTag   = i_tag;
                    nextIndex = i_index;
                    nextBlock = Block'(0);
                    nextState = State_READ;
                end
            end

            State_READ: begin
                o_tag     = tag;
                o_index   = index;
                o_block   = block;
                o_write   = 1'b1;
                nextBlock = block + Block'(1);
                if (Block'(block) == Block'(BLOCKS-1))
                    nextState = State_LOOKUP;
            end
        endcase
        // verilator lint_on CASEINCOMPLETE

    end

    // Actualitza els contadors
    //
    always_ff @(posedge i_clock)
        if (i_reset) begin
            tag   <= Tag'(0);
            index <= Index'(0);
            block <= Block'(0);
        end
        else begin
            tag   <= nextTag;
            index <= nextIndex;
            block <= nextBlock;
        end

    // Actualitza l'estat
    //
    always_ff @(posedge i_clock)
        if (i_reset)
            state <= State_RESET;
        else
            state <= nextState;

endmodule
