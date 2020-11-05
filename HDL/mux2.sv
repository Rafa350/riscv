module mux2
#(
    parameter WIDTH = 32)
(
    input  logic             i_sel,
    
    input  logic [WIDTH-1:0] i_in0,
    input  logic [WIDTH-1:0] i_in1,
    
    output logic [WIDTH-1:0] o_out);

    assign o_out = i_sel ? i_in1 : i_in0;

endmodule