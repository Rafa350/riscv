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
//            o_cacheWrite   : Habilita escriptura en el cache
//            o_cacheClear   : Habilita inicialitzacio del cache
//            o_hit          : Indica coincidencia
//            o_busy         : Indica ocupat. O be per inicialitzacio
//                             o per escriptura en cache
//
//       Notes:
//            En cas d'activacio de 'i_reset', s'inicia el proces
//            d'inicialitzacio de la cache, es posa 'o_cacheClear' en 1,
//            i 'o_busy' en 1, durant els cicles necesaris per la
//            inicialitzacio del cac     he. En cada cicle 'o_index' indica
//            la linia de cache que cal inicialitzar. Un cop finalitzat
//            el process, 'o_cacheClear' passa a 0, 'o_busy' passa a 0,
//            i 'o_index' s'assigna al valor de 'i_index'.
//            En cas d'activar 'i_rd', si hi ha coincidentia, perque aixi
//            ho indica la entrada 'i_hit', el senyal 'o_hit' passa a 1.
//            Si 'i_hit' es 0, es a dir, no hi ha coincidencia, s'inicia
//            el proces de lectura de la memoria, aleshores 'o_tag',
//            'o_index' i 'o_block', indican l'adressa de memoria a
//            lleigit, i 'o_cacheWrite' indica que cal escriure el bloc en el
//            cache en l'ultim cicle de lectura del bloc.
//
// -----------------------------------------------------------------------

module ICacheController
#(
    parameter TAG_WIDTH    = 3, // Amplada del tag en bits
    parameter INDEX_WIDTH  = 5, // Amplada del index en bits
    parameter OFFSET_WIDTH = 2) // Amplada del offset en bits
(
    input  logic                    i_clock,      // Clock
    input  logic                    i_reset,      // Reset
    input  logic                    i_hit,        // Indica coincidencia
    input  logic                    i_re,         // Habilita la lectura
    input  logic [TAG_WIDTH-1:0]    i_tag,        // Tag
    input  logic [INDEX_WIDTH-1:0]  i_index,      // Index
    input  logic [OFFSET_WIDTH-1:0] i_offset,     // Offset
    output logic [TAG_WIDTH-1:0]    o_tag,        // Tag
    output logic [INDEX_WIDTH-1:0]  o_index,      // Index
    output logic [OFFSET_WIDTH-1:0] o_offset,     // Offset
    output logic                    o_cacheWrite, // Habilita escriptura en el cache
    output logic                    o_cacheClear, // Habilita neteja en el cache
    output logic                    o_memRead,    // Habilita lectura de memoria
    output logic                    o_hit,        // Indica coincidencia
    output logic                    o_busy);      // Indica ocupat


    typedef enum logic [1:0] { // Estats de la maquina
        State_RESET,           // -Reset inicial
        State_CLEAR,           // -Neteja del cache
        State_LOOKUP,          // -Consulta dades en la cache
        State_READ             // -Actualitzacio del cache
    } State;

    typedef logic [TAG_WIDTH-1:0]    Tag;
    typedef logic [INDEX_WIDTH-1:0]  Index;
    typedef logic [OFFSET_WIDTH-1:0] Offset;


    Tag    tag;        // Tag
    Tag    nextTag;    // Seguent valor de 'tag'
    Index  index;      // Index a la linia de cache
    Index  nextIndex;  // Seguent valor de 'index'
    Offset offset;     // Offset dins de la linia de cache
    Offset nextOffset; // Seguent valor de 'offset'

    State state;      // Estat de la maquina
    State nextState;  // Seguent valor de 'state'


    always_comb begin

        o_tag        = i_tag;
        o_index      = i_index;
        o_offset     = i_offset;
        o_cacheWrite = 1'b0;
        o_cacheClear = 1'b0;
        o_memRead    = 1'b0;
        o_hit        = 1'b0;
        o_busy       = 1'b1;

        nextState  = state;
        nextTag    = tag;
        nextIndex  = index;
        nextOffset = offset;

        // verilator lint_off CASEINCOMPLETE
        unique case (state)
            State_RESET: begin
                nextIndex = Index'(0);
                nextState = State_CLEAR;
            end

            State_CLEAR: begin
                o_index = index;
                o_cacheClear = 1'b1;
                nextIndex = index + Index'(1);
                if (Index'(index) == Index'((2**$size(index))-1))
                    nextState = State_LOOKUP;
            end

            State_LOOKUP: begin
                o_hit  = i_hit;
                o_busy = 1'b0;
                if (~i_hit & i_re) begin
                    nextTag    = i_tag;
                    nextIndex  = i_index;
                    nextOffset = Offset'(0);
                    nextState  = State_READ;
                end
            end

            State_READ: begin
                o_tag        = tag;
                o_index      = index;
                o_offset     = offset;
                o_cacheWrite = 1'b1;
                o_memRead    = 1'b1;
                nextOffset   = offset + Offset'(1);
                if (Offset'(offset) == Offset'((2**$size(offset))-1))
                    nextState = State_LOOKUP;
            end
        endcase
        // verilator lint_on CASEINCOMPLETE

    end

    // Actualitza els contadors
    //
    always_ff @(posedge i_clock)
        if (i_reset) begin
            tag    <= Tag'(0);
            index  <= Index'(0);
            offset <= Offset'(0);
        end
        else begin
            tag    <= nextTag;
            index  <= nextIndex;
            offset <= nextOffset;
        end

    // Actualitza l'estat
    //
    always_ff @(posedge i_clock)
        if (i_reset)
            state <= State_RESET;
        else
            state <= nextState;

endmodule
