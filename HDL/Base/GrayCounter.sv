// Simulation and Synthesis Techniques for Asynchronous
// FIFO Design with Asynchronous Pointer Comparisons
// By Clifford E. Cummings

// Optimitzacio basada en que el bit MSB del codi gray es igual al 
// correesponent binary per tant en el registre o_Output ens 
// estalviem un ff

module GrayCounter
#(
    parameter DATA_WIDTH = 4)
(
    input  logic                  i_Clock,
    input  logic                  i_Reset,
    input  logic [DATA_WIDTH-1:0] i_Increment,
    input  logic                  i_IncEnable,
    output logic [DATA_WIDTH-1:0] o_Output);
    
    
    logic [DATA_WIDTH-1:0] B, BNext, GNext;
    logic [DATA_WIDTH-2:0] O;
   
    assign BNext = B + (i_IncEnable ? i_Increment : 'b0);
    assign GNext = (BNext >> 1) ^ BNext;

    always_ff @(posedge i_Clock) begin
        B <= i_Reset ? 'b0 : BNext;
        O <= i_Reset ? 'b0 : GNext[DATA_WIDTH-2:0];
    end
    
    assign o_Output = {BNext[DATA_WIDTH-1], O};
    
endmodule
