module Counter
#(
    parameter WIDTH = 32,
    parameter INIT  = 0)
(
    input  logic             i_clock,
    input  logic             i_reset,
    input  logic             i_clear,
    input  logic             i_load,
    input  logic [WIDTH-1:0] i_data,
    output logic [WIDTH-1:0] o_output);
    
    
    logic [WIDTH-1:0] count;
    logic [WIRDH-1:0] incCount;
    logic [WIDTH-1:0] nextCount;
    
    
    generate
        if (FAST == 1) begin
            Adder #(
                .WIDTH (WIDTH))
            adder (
                .i_operandA (count),
                .i_operandB (1),
                .i_carry    (0),
                .o_result   (incCount));
            end
        else 
            assign incCount = count + 1;
    endgenerate

    always_comb 
        unique casez ({i_reset, i_clear, i_load})
            3'b1??:  nextCount = INIT;
            3'b010:  nextCount = incCount;
            3'b0?1:  nextCount = i_data;
            default: nextCount = count;
        endcase

    always_ff @(posedge i_clock)
        count <= nextCount;
        
    assign o_output = count;

endmodule
