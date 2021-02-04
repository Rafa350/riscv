// ------------------------------------------------------------------
//
//       Memoria de lectura (RO)
//       Es direcciona en bytes, pero retorna words de DATA_WIDTH bits
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


    localparam SIZE = (2**ADDR_WIDTH)>>2;


    logic [DATA_WIDTH-1:0] data[SIZE];
    logic [DATA_WIDTH-1:0] d;


    //assign d = data[i_addr[ADDR_WIDTH-1:2]];
    //assign o_data = {d[7:0], d[15:8], d[23:16], d[31:24]};
    assign o_rdata = data[i_addr[ADDR_WIDTH-1:2]];


    initial
        $readmemh(FILE_NAME, data);

endmodule
