module register
#(
    parameter WIDTH = 32,
    parameter INIT = 0)
(
    input  logic             i_clk,
    input  logic             i_rst,
    
    input  logic             i_we,
   
    input  logic [WIDTH-1:0] i_wdata,
    output logic [WIDTH-1:0] o_rdata);
    
    initial
        o_rdata = INIT;
      
    always_ff @(posedge i_clk)
        case ({i_rst, i_we} )
            2'b00: o_rdata <= o_rdata;
            2'b01: o_rdata <= i_wdata;
            2'b10: o_rdata <= INIT;
            2'b11: o_rdata <= INIT;
        endcase
    
endmodule
