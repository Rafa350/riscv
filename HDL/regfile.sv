// -----------------------------------------------------------------------
// Implementa un bloc de registres tipus MIPS
// -Un port d'entrada per escriptura del registre 1..N
// -Dos ports independents de lectura dels registres 0 a N
// -El registre 0 sempre val zero
// -Durant el reset, tots els registres s'asignen al valor zero.
//
module regfile
#(
    parameter DATA_WIDTH = 32,                   // Amplada del bus de dades
    parameter REG_WIDTH = 5)                     // Amplada del nombre de registre
(
    // Control
    input logic i_clk,                           // Clock
    input logic i_rst,                           // Reset
    
    // Port d'escriptura
    input logic [REG_WIDTH-1:0] i_wreg,          // Write register
    input logic [DATA_WIDTH-1:0] i_wdata,        // Write data 
    input logic i_we,                            // Write enable
    
    // Port de lectura A
    input logic [REG_WIDTH-1:0] i_rregA,         // Read register A
    output logic [DATA_WIDTH-1:0] o_rdataA,      // Read data A
    
    // Port de lectura B
    input logic [REG_WIDTH-1:0] i_rregB,         // Read register B
    output logic [DATA_WIDTH-1:0] o_rdataB);     // Read data B
    
    localparam MAX_REG = (2**REG_WIDTH)-1;
    
    logic [DATA_WIDTH-1:0] data[1:MAX_REG];
    logic [DATA_WIDTH-1:0] zero = 0;
    
    always_ff @(posedge i_clk)
        if (i_rst) begin
            integer i;
            for (i = 1; i <= MAX_REG; i++)
                data[i] <= zero;
        end                
        else if (i_we & (i_wreg != 0))
            data[i_wreg] <= i_wdata;
            
    assign o_rdataA = (i_rregA == 0) ? zero : data[i_rregA];
    assign o_rdataB = (i_rregB == 0) ? zero : data[i_rregB];

endmodule
