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
//           i_Addr     : Adresa de lectura.
//
//       Sortida:
//           o_RdData   : Dades lleigides.
//
// -----------------------------------------------------------------------

module RoMemory 
#(
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 32,
    parameter FILE_NAME  = "data.txt")
(
    input  logic [ADDR_WIDTH-1:0] i_Addr,    // Adressa en bytes
    output logic [DATA_WIDTH-1:0] o_RdData); // Dades lleigides lectura
    
    localparam SIZE = (2**ADDR_WIDTH)>>2;

    
    logic [DATA_WIDTH-1:0] Data[SIZE];
    logic [DATA_WIDTH-1:0] d;
    
    assign d = Data[i_Addr[ADDR_WIDTH-1:2]];   
    assign o_RdData = {d[7:0], d[15:8], d[23:16], d[31:24]};
             
    initial
        $readmemh(FILE_NAME, Data);
   
endmodule
