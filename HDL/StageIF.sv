module StageIF
#(
    parameter DATA_IBUS_WIDTH          = 32,         // Ampla de dades del bus d'instruccions
    parameter ADDR_IBUS_WIDTH          = 32)         // Ampla de adressa del bus d'instruccions
(
    input  logic                       i_Clock,      // Clock
    input  logic                       i_Reset,      // Reset    
    
    input  logic [DATA_IBUS_WIDTH-1:0] i_PgmInst,    // Instruccio de programa
    output logic [ADDR_IBUS_WIDTH-1:0] o_PgmAddr,    // Adressa de programa

    input  logic                       i_JumpEnable, // Habilita el salt
    input  logic [ADDR_IBUS_WIDTH-1:0] i_JumpAddr,   // Adressa de salt
    
    output logic [DATA_IBUS_WIDTH-1:0] o_Inst,       // Instruccio
    output logic [ADDR_IBUS_WIDTH-1:0] o_PC);        // Adressa de la instruccio


    logic [DATA_IBUS_WIDTH-1:0] Inst;      // La intruccio actual
    logic [ADDR_IBUS_WIDTH-1:0] PC,        // El PC
                                PCPlus4;   // El PC + 4


    HalfAdder #(
        .WIDTH (ADDR_IBUS_WIDTH))
    adder1 (
        .i_OperandA (PC),
        .i_OperandB (4),
        .o_Output   (PCPlus4));
    
    always_ff @(posedge i_Clock)
        case {i_Reset, i_JumpEnable)
            2'b00: PC <= PCPlus4;
            2'b01: PC <= PCJumpAddr;
            2'b10: PC <= 0;
            2'b11: PC <= 0;
        endcase
                   
                   
    // Interface amb la memoria de programa
    //
    assign o_PgmAddr = PC; 
    assign Inst = i_PgmInst;


    // Registres pipeline de sortida
    //
    always_ff @(posedge i_Clock) begin
        o_PC   <= i_Reset ? 0 : PC;
        o_Inst <= i_Reset ? 0 : Inst;
    end

endmodule
