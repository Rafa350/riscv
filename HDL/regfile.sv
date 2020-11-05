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
    input logic i_clk,                           // Clock. 
    input logic i_rst,                           // Reset
    
    // Port d'escriptura
    input logic [REG_WIDTH-1:0]  i_wr_reg,       // Identificador del registre del port escriptura
    input logic [DATA_WIDTH-1:0] i_wr_data,      // Dades d'escriptura
    input logic                  i_we,           // Habilita l'escriptura
    
    // Port de lectura A
    input  logic [REG_WIDTH-1:0]  i_rd_reg_A,    // Identificador del registre del port de lectura A
    output logic [DATA_WIDTH-1:0] o_rd_data_A,   // Dades lleigides del port A
    
    // Port de lectura B
    input  logic [REG_WIDTH-1:0]  i_rd_reg_B,    // Identificador del regisres del port de lectura B
    output logic [DATA_WIDTH-1:0] o_rd_data_B);  // Dades lleigides del port B
    
    localparam MAX_REG = (2**REG_WIDTH)-1;
    
    logic [DATA_WIDTH-1:0] data[1:MAX_REG];
    logic [DATA_WIDTH-1:0] zero = 0;
    
    always_ff @(posedge i_clk)
        if (i_rst) begin
            integer i;
            for (i = 1; i <= MAX_REG; i++)
                data[i] <= zero;
        end                
        else if (i_we & (i_wr_reg != 0))
            data[i_wr_reg] <= i_wr_data;
            
    assign o_rd_data_A = (i_rd_reg_A == 0) ? zero : data[i_rd_reg_A];
    assign o_rd_data_B = (i_rd_reg_B == 0) ? zero : data[i_rd_reg_B];

endmodule
