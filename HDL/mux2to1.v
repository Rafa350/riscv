/*************************************************************************
 *
 *       Selector de 2 a 1
 *
 *       Parametres:
 *           DATA_WIDTH : Amplada del bus
 *
 *       Entrades:
 *           i_data0 : Bus d'entrada A
 *           i_data1 : Bus d'entrada B
 *           i_sel   : Seleccio
 *
 *       Sortides:
 *           o_data  : Bus de sortida
 *
 *************************************************************************/
 
module mux2to1
#(
    parameter DATA_WIDTH = 16)
(
    input wire [DATA_WIDTH-1:0] i_data0,
    input wire [DATA_WIDTH-1:0] i_data1,
    input i_sel,
    output wire [DATA_WIDTH-1:0] o_data);
    
    assign o_data = i_sel == 0 ? i_data0 : i_data1;

endmodule
