// -----------------------------------------------------------------------
// Implementa un bloc de registres tipus MIPS
// -Un port d'entrada per escriptura del registre 1..N
// -Dos ports independents de lectura dels registres 0 a N
// -El registre 0 sempre val zero
// -Durant el reset, tots els registres s'asignen al valor zero.
//
module regfile
#(
    parameter DATA_WIDTH = 32,               // Amplada del bus de dades
    parameter ADDR_WIDTH = 5)                // Amplada del bus d'adreses
(
    // Control
    input logic i_clk,                       // Clock
    input logic i_rst,                       // Reset
    
    // Port d'escriptura
    input logic [ADDR_WIDTH-1:0] i_waddr,    // Identificador del registre del port escriptura
    input logic [DATA_WIDTH-1:0] i_wdata,    // Dades d'escriptura
    input logic                  i_we,       // Habilita l'escriptura
    
    // Port de lectura A
    input  logic [ADDR_WIDTH-1:0] i_raddrA,  // Identificador del registre del port de lectura A
    output logic [DATA_WIDTH-1:0] o_rdataA,  // Dades lleigides del port A
    
    // Port de lectura B
    input  logic [ADDR_WIDTH-1:0] i_raddrB,  // Identificador del regisres del port de lectura B
    output logic [DATA_WIDTH-1:0] o_rdataB); // Dades lleigides del port B
    
    localparam NUM_REGS = 2**ADDR_WIDTH;
    
    logic [DATA_WIDTH-1:0] data[1:NUM_REGS-1];
    logic [DATA_WIDTH-1:0] zero = {DATA_WIDTH{1'b0}};
    
    always_ff @(posedge i_clk)
        if (i_rst) begin
            integer i;
            for (i = 1; i < NUM_REGS; i++)
                data[i] <= zero;
        end                
        else if (i_we & (i_waddr != 0))
            data[i_waddr] <= i_wdata;
            
    always_comb begin            
        o_rdataA = (i_raddrA == 0) ? zero : data[i_raddrA];
        o_rdataB = (i_raddrB == 0) ? zero : data[i_raddrB];
    end

endmodule
