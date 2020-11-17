module StageIF
#(
    parameter DATA_IBUS_WIDTH          = 32,         // Ampla de dades del bus d'instruccions
    parameter ADDR_IBUS_WIDTH          = 32)         // Ampla de adressa del bus d'instruccions
(
    // Senyals de timing
    //
    input  logic                       i_Clock,      // Clock
    input  logic                       i_Reset,      // Reset    
    
    // Interface amb la memoria de programa
    //
    input  logic [DATA_IBUS_WIDTH-1:0] i_PgmInst,    // Instruccio de programa
    output logic [ADDR_IBUS_WIDTH-1:0] o_PgmAddr,    // Adressa de programa

    // Entrades de control
    //
    input  logic                       i_JumpEnable, // Habilita el salt
    input  logic [ADDR_IBUS_WIDTH-1:0] i_JumpAddr,   // Adressa de salt
    
    // Sortides del pipeline
    //
    output logic [DATA_IBUS_WIDTH-1:0] o_Inst,       // Instruccio
    output logic [ADDR_IBUS_WIDTH-1:0] o_PC);        // Adressa de la instruccio


    logic [DATA_IBUS_WIDTH-1:0] Inst; // Instruccio
    logic [ADDR_IBUS_WIDTH-1:0] PC;   // Adressa de la instruccio


    always_ff @(posedge i_Clock) begin
        unique casez ({i_Reset, i_JumpEnable})
            2'b00: PC <= PC + 4;
            2'b01: PC <= i_JumpAddr;
            2'b1?: PC <= 0;
        endcase
        Inst <= i_Reset ? 0 : i_PgmInst;
    end 
    assign o_PC      = i_Reset ? 0 : PC;
    assign o_Inst    = i_Reset ? 0 : Inst;    
    assign o_PgmAddr = PC; 

endmodule
