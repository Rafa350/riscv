/*************************************************************************
 *
 *       Genera els senyals CLK i RST del sistema
 *
 *       Entrades:
 *           i_clk   : Senyal de rellotge extern
 *           i_rst   : Senyal de reset del extern
 *           i_pause : Pausa el rellotje
 *
 *       Sotides:
 *           o_clk   : Senyal de rellotge
 *           o_rst   : Senyal de reset
 *
 *************************************************************************/

/* verilator lint_off UNOPTFLAT */
/* verilator lint_off UNUSED */

module clock(
    input logic i_clk,
    input logic i_rst,
    input logic i_pause,
    output logic o_clk,
    output logic o_rst);
    
    logic q1, q2;
    
    always_ff @(posedge i_clk, posedge i_rst) begin
        if (i_rst) begin
            q1 <= 0;
            q2 <= 0;
            o_rst <= 1;
        end 
        
        else begin
            q1 <= 1;
            q2 <= q1;
            o_rst <= 0;
        end
    end
        
    assign o_clk = i_clk & q2;

endmodule
