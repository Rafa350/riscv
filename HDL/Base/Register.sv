module Register
#(
    parameter WIDTH = 32,              // Amplada de dades en bits
    parameter INIT  = 32'd0)           // Valor per reset
(
    input  logic             i_clock,  // Clock
    input  logic             i_reset,  // Reset. Asigna el valor inicial (INIT)

    input  logic             i_we,     // Habilita l'escriptura en el registre

    input  logic [WIDTH-1:0] i_wdata,  // Dades per escriure (Sincron amb i_Clock)
    output logic [WIDTH-1:0] o_rdata); // Dades lleigides (Asincron)


    logic [WIDTH-1:0] data;


    initial
        data = INIT;


    always_ff @(posedge i_clock)
        unique case ({i_reset, i_we})
            2'b00: data <= data;
            2'b01: data <= i_wdata;
            2'b10: data <= INIT;
            2'b11: data <= INIT;
        endcase

    assign o_rdata = i_reset ? INIT : data;

endmodule
