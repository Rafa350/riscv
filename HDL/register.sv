module register
#(
    parameter WIDTH = 32)
(
    input  logic             i_clk,
    input  logic             i_rst;
    
    input  logic [WIDTH-1:0] i_data,
    output logic [WIDTH-1:0] o_data);
      
    always_ff @(posedge i_clk)
        if (i_rst)
            o_data <= 0;
        else
            o_data <= i_data;
    
endmodule
