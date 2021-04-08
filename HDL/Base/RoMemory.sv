// ------------------------------------------------------------------
//
//       Memoria de lectura (RO)
//
//       Parametres:
//           DATA_WIDTH : Amplada del bus de dades.
//           ADDR_WIDTH : Amplada del bus d'adressa.
//           FILE_NAME  : El fitxer d'inicialitzacio.
//
//       Entrada:
//           i_addr     : Adresa de lectura.
//
//       Sortida:
//           o_rdata    : Dades lleigides.
//
// -----------------------------------------------------------------------

module RoMemory
#(
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 32,
    parameter FILE_NAME  = "data.txt")
(
    input  logic [ADDR_WIDTH-1:0] i_addr,   // Adressa en bytes
    output logic [DATA_WIDTH-1:0] o_rdata); // Dades lleigides lectura


    localparam int unsigned SIZE = 2**ADDR_WIDTH;


    logic [DATA_WIDTH-1:0] data[SIZE];
    logic [DATA_WIDTH-1:0] d;


    assign o_rdata = data[i_addr[ADDR_WIDTH-1:0]];


    initial
        $readmemh(FILE_NAME, data);

endmodule
