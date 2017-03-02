/*************************************************************************
 *
 *       Implementa un contador sincron
 *
 *       Parametres:
 *           DATA_WIDTH : Amplada bits del contador
 *
 *       Entrades:
 *           i_clk  : Clock
 *           i_rst  : Reset
 *           i_le   : Autoritza la carrega del valor inicial
 *           i_data : Valor inicial del contador
 *
 *       Sortides:
 *           o_data : Valor actual del contador. S'actualitza en el flanc
 *                    positiu de 'clk'
 *
 *************************************************************************/

module counter
#(
    parameter DATA_WIDTH = 16)
(
    input i_clk,
    input i_rst,
    input i_le,
    input [DATA_WIDTH-1:0] i_data,
    output reg [DATA_WIDTH-1:0] o_data);

    always_ff @(posedge i_clk) begin
        case ({i_rst, i_le})
            2'b00: o_data <= o_data + {{DATA_WIDTH-1{1'b0}}, 1'b1};
            2'b01: o_data <= i_data;
            2'b10: o_data <= 0;
            2'b11: o_data <= 0;
        endcase
    end

endmodule
