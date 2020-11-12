// -----------------------------------------------------------------------
// Implementa un bloc de registres tipus MIPS
// -Un port d'entrada per escriptura del registre 1..N
// -Dos ports independents de lectura dels registres 0 a N
// -El registre 0 sempre val zero
// -Durant el reset, tots els registres s'asignen al valor zero.
//
module RegisterFile
#(
    parameter DATA_WIDTH = 32,               // Amplada del bus de dades
    parameter ADDR_WIDTH = 5)                // Amplada del bus d'adreses
(
    // Control
    input logic i_Clock,                     // Clock
    input logic i_Reset,                     // Reset
    
    // Port d'escriptura
    input logic [ADDR_WIDTH-1:0] i_WrAddr,   // Identificador del registre del port escriptura
    input logic [DATA_WIDTH-1:0] i_WrData,   // Dades d'escriptura
    input logic                  i_WrEnable, // Habilita l'escriptura
    
    // Port de lectura A
    input  logic [ADDR_WIDTH-1:0] i_RdAddrA, // Identificador del registre del port de lectura A
    output logic [DATA_WIDTH-1:0] o_RdDataA, // Dades lleigides del port A
    
    // Port de lectura B
    input  logic [ADDR_WIDTH-1:0] i_RdAddrB,  // Identificador del regisres del port de lectura B
    output logic [DATA_WIDTH-1:0] o_RdDataB); // Dades lleigides del port B
    
    localparam NUM_REGS = 2**ADDR_WIDTH;
    localparam ZERO = {DATA_WIDTH{1'b0}};
    
    logic [DATA_WIDTH-1:0] Data[1:NUM_REGS-1];

    always_ff @(posedge i_Clock)
        if (i_Reset) begin
            integer i;
            for (i = 1; i < NUM_REGS; i++)
                Data[i] <= ZERO;
        end                
        else if (i_WrEnable & (|i_WrAddr))
            Data[i_WrAddr] <= i_WrData;
    
    always_comb begin            
        o_RdDataA = (i_Reset | (~|i_RdAddrA)) ? ZERO : Data[i_RdAddrA];
        o_RdDataB = (i_Reset | (~|i_RdAddrB)) ? ZERO : Data[i_RdAddrB];
    end

endmodule
