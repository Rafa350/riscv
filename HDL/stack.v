/*************************************************************************
 *
 *       Implementa una pila lifo (STACK) 
 *
 *       Parametres
 *           WIDTH: Amplada del bus de dades
 *           DEPTH: Profunditat de la pila
 *
 *       Entrades:
 *           clk  : Clock
 *           we   : Write enable
 *           me   : Move enable
 *           md   : Move direction
 *                   -0: UP
 *                   -1: DOWN
 *           in   : Data input
 *
 *       Sortides:
 *           out  : Data output
 *
 *************************************************************************/

module stack
#(
    parameter WIDTH = 16,
    parameter DEPTH = 10)
( 
    input wire clk,
    output wire [WIDTH-1:0] out,
    input wire we,
    input wire me,
    input wire md,
    input wire [WIDTH-1:0] in);
  
    localparam BITS = (WIDTH * DEPTH) - 1;

    reg [WIDTH-1:0] head;
    reg [BITS:0] tail;
    wire [WIDTH-1:0] headN;
    wire [BITS:0] tailN;

    assign headN = we ? in : tail[WIDTH-1:0];
    assign tailN = md ? {{WIDTH{1'b0}} , tail[BITS:WIDTH]} : {tail[BITS-WIDTH:0], head};

    always @(posedge clk) begin
        if (we | me)
            head <= headN;
        if (me)
            tail <= tailN;
    end

    assign out = head;

endmodule
