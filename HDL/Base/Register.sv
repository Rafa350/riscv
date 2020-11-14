module Register
#(
    parameter WIDTH = 32,                // Amplada de dades
    parameter INIT  = 32'd0)             // Valor per reset
(
    input  logic             i_Clock,    // Clock
    input  logic             i_Reset,    // Reset. Asigna el valor inicial (INIT)

    input  logic             i_WrEnable, // Habilita l'escriptura en el registre

    input  logic [WIDTH-1:0] i_WrData,   // Dades per escriure (Sincron amb i_Clock)
    output logic [WIDTH-1:0] o_RdData);  // Dades lleigides (Asincron)

    logic [WIDTH-1:0] Data;

    initial
        Data = INIT;

    always_ff @(posedge i_Clock)
        unique case ({i_Reset, i_WrEnable})
            2'b00: Data <= Data;
            2'b01: Data <= i_WrData;
            2'b10: Data <= INIT;
            2'b11: Data <= INIT;
        endcase

    assign o_RdData = i_Reset ? INIT : Data;

endmodule
