/*************************************************************************
 *
 *       Selector de 4 a 1
 *
 *       Parametres:
 *           DATA_WIDTH : Amplada del bus
 *
 *       Entrades:
 *           i_data0 : Bus d'entrada A
 *           i_data1 : Bus d'entrada B
 *           i_data2 : Bus d'entrada C
 *           i_data3 : Bus d'entrada D
 *           i_sel   : Seleccio
 *
 *       Sortides:
 *           o_data  : Bus de sortida
 *
 *************************************************************************/
 
module mux4to1
#(
    parameter DATA_WIDTH = 16)
(
    input [DATA_WIDTH-1:0] i_data0,
    input [DATA_WIDTH-1:0] i_data1,
    input [DATA_WIDTH-1:0] i_data2,
    input [DATA_WIDTH-1:0] i_data3,
    output [DATA_WIDTH-1:0] o_data,
    input [1:0] i_sel);
    
    always_comb 
        case (i_sel)
            2'b00 : o_data = i_data0;
            2'b01 : o_data = i_data1;
            2'b10 : o_data = i_data2;
            2'b11 : o_data = i_data3;
        endcase

endmodule
