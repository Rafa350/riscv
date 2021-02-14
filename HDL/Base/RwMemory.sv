// -----------------------------------------------------------------------
//
//       Memoria de lectura/escriptura.
//
//       Lectura asincrona i escriptura sincrona.
//       Un canal per lectura, i un altre per escriptura.
//       Escriptura i lectura simultanies.
//       Es direcciona en bytes pero retorna word de DATA_WIDTH bits
//
//       Parametres:
//           DATA_WIDTH : Amplada del canal de dades
//           ADDR_WIDTH : Amplada del canal d'adresses
//
//       Entrades:
//           i_clock    : Rellrotge
//           i_addr     : Adressa per escriptura i/o lectura
//           i_we       : Habilita l'escriptura
//           i_wdata    : Dades per escriure
//
//       Sortides:
//           o_rdata    : Dades lleigides
//
// -----------------------------------------------------------------------

module RwMemory
#(
    parameter int unsigned DATA_WIDTH = 32, // Amplade de dades
    parameter int unsigned ADDR_WIDTH = 32) // Amplada d'adresses
(
    input  logic                  i_clock,  // Clock

    input  logic [ADDR_WIDTH-1:0] i_addr,   // Adressa
    input  logic                  i_we,     // Habilita l'escriptura
    input  logic [DATA_WIDTH-1:0] i_wdata,  // Dades per escriure
    output logic [DATA_WIDTH-1:0] o_rdata); // Dades lleigides

    localparam int unsigned SIZE = (2**ADDR_WIDTH)>>2;

    logic [DATA_WIDTH-1:0] data [SIZE];

    always_ff @(posedge i_clock)
        if (i_we)
            data[i_addr[ADDR_WIDTH-1:2]] <= i_wdata;

    assign o_rdata = data[i_addr];

endmodule
