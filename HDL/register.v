/*************************************************************************
 *
 *       Implementa un registre
 *
 *       Parametres:
 *           DATA_WIDTH : Amplada del bus de dades
 *
 *       Entrada:
 *           i_clk  : Clock
 *           i_rst  : Reset
 *           i_data : Bus d'entrada
 *
 *       Sortida:
 *           o_data : Bus de sortida
 *
 *************************************************************************/
 
module register
#(
    parameter DATA_WIDTH = 16)
(
    input i_clk,
    input i_rst,
    input [DATA_WIDTH-1:0] i_data,
    output reg [DATA_WIDTH-1:0] o_data);
    
    always_ff @(posedge i_clk) begin
        if (i_rst)
            o_data <= 0;
        else 
            o_data <= i_data;
    end
    
endmodule