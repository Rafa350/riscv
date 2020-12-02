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
//           i_Clock    : Rellrotge
//           i_Addr     : Adressa per escriptura i/o lectura
//           i_WrEnable : Habilita l'escriptura
//           i_WrData   : Dades per escriure
//
//       Sortides:
//           o_RdData   : Dades lleigides
//
// -----------------------------------------------------------------------

module RwMemory
#(
    parameter DATA_WIDTH = 32, // Amplade de dades
    parameter ADDR_WIDTH = 32) // Amplada d'adresses
(
    input  logic                  i_Clock,    // Clock

    input  logic [ADDR_WIDTH-1:0] i_Addr,     // Adressa
    input  logic                  i_WrEnable, // Habilita l'escriptura
    input  logic [DATA_WIDTH-1:0] i_WrData,   // Dades per escriure
    output logic [DATA_WIDTH-1:0] o_RdData);  // Dades lleigides

    localparam SIZE = (2**ADDR_WIDTH)>>2;

    logic [DATA_WIDTH-1:0] Data [0:SIZE-1];

    always_ff @(posedge i_Clock)
        if (i_WrEnable)
            Data[i_Addr[ADDR_WIDTH-1:2]] <= i_WrData;

    assign o_RdData = Data[i_Addr];
    
 
endmodule
