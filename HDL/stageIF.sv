


module stageIF
#(
    parameter DATA_IBUS_WIDTH          = 32,         // Ampla de dades del bus d'instruccions
    parameter ADDR_IBUS_WIDTH          = 32)         // Ampla de adressa del bus d'instruccions
(
    // Senyals de control
    //
    input  logic                       i_Clock,      // Clock
    input  logic                       i_Reset,      // Reset    
    
    // Interface amb la memoria de programa
    //
    input  logic [DATA_IBUS_WIDTH-1:0] i_PgmInst,    // Instruccio de programa
    output logic [ADDR_IBUS_WIDTH-1:0] o_PgmAddr,    // Adressa del programa

    // Entrades del pipeline     
    //
    input  logic                       i_JumpEnable, // Seleccio del seguent PC (1: Salta)
    input  logic [ADDR_IBUS_WIDTH-1:0] i_JumpAddr,   // Adressa de salt
    
    // Sortides del pipeline 
    //
    output logic [DATA_IBUS_WIDTH-1:0] o_Inst,       // Instruccio actual
    output logic [ADDR_IBUS_WIDTH-1:0] o_PCPlus4);   // Adressa de la propera instruccio


    logic [DATA_IBUS_WIDTH-1:0] Inst;      // La intruccio actual
    logic [ADDR_IBUS_WIDTH-1:0] PC,        // El PC
                                PCPlus4,   // El PC + 4
                                PCNext;    // El proper PC


    // Contador de programa
    //
    always_comb begin
        PCPlus4 = PC + 4;
        PCNext  = i_JumpEnable ? i_JumpAddr : PCPlus4;
    end
    always_ff @(posedge i_Clock)
        PC <= i_Reset ? 0 : PCNext;
                   
                   
    // Interface amb la memoria de programa
    //
    assign o_PgmAddr = PC; 
    assign Inst = i_PgmInst;


    // Registres pipeline de sortida
    //
    always_ff @(posedge i_Clock) begin
        o_PCPlus4 <= i_Reset ? 0 : PCPlus4;
        o_Inst    <= i_Reset ? 0 : Inst;
    end

endmodule
