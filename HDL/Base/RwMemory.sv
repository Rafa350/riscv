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
    
    localparam SIZE = 2**ADDR_WIDTH;

    logic [DATA_WIDTH-1:0] Data [0:SIZE-1];
      
    always_ff @(posedge i_Clock)
        if (i_WrEnable)
            Data[i_Addr] <= i_WrData;            
            
    assign o_RdData = Data[i_Addr];

endmodule
