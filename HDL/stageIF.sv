module stageIF
#(
    parameter DATA_IBUS_WIDTH          = 32,       // Ampla de dades del bus d'instruccions
    parameter ADDR_IBUS_WIDTH          = 32)       // Ampla de adressa del bus d'instruccions
(
    // Senyals de control
    //
    input  logic                       i_Clock,    // Clock
    input  logic                       i_Reset,    // Reset    
    
    // Interface amb la memoria de programa
    //
    input  logic [DATA_IBUS_WIDTH-1:0] i_PgmInst,  // Instruccio de programa
    output logic [ADDR_IBUS_WIDTH-1:0] o_PgmAddr,  // Adressa del programa

    // Entrades del pipeline     
    //
    input  logic                       i_PCSrc,    // Seleccio del seguent PC
    input  logic [ADDR_IBUS_WIDTH-1:0] i_PCBranch, // Adressa de salt
    
    // Sortides del pipeline 
    //
    output logic [DATA_IBUS_WIDTH-1:0] o_Inst,     // Instruccio actual
    output logic [ADDR_IBUS_WIDTH-1:0] o_PCPlus4); // Adressa de la propera instruccio
    
    
    // Gestio del contador de programa
    //
    logic [ADDR_IBUS_WIDTH-1:0] PC,        // Adressa de la instruccio actual
                                PCPlus4,   // Adresa de la seguent instruccio en memnoria
                                PCNext;    // Adresa de la seguent instruccio a saltar
   
    HalfAdder #(
        .WIDTH (ADDR_IBUS_WIDTH))
    PCAdd (
        .i_OperandA (PC),
        .i_OperandB (4),
        .o_Result   (PCPlus4));
        
    Mux2To1 #(
        .WIDTH (ADDR_IBUS_WIDTH))
    PCSel (
        .i_Select (i_PCSrc),
        .i_Input0 (PCPlus4),
        .i_Input1 (i_PCBranch),
        .o_Output (PCNext));
    
    Register #(
        .WIDTH (ADDR_IBUS_WIDTH),
        .INIT  (0))
    PCReg (
        .i_Clock    (i_Clock),
        .i_Reset    (i_Reset),
        .i_WrEnable (1),
        .i_WrData   (PCNext),
        .o_RdData   (PC));
        
            
    // Interface amb la memoria de programa
    //
    assign o_PgmAddr = PC; 


    // Registres pipeline de sortida
    //
    always_ff @(posedge i_Clock) begin
        o_PCPlus4 <= PCPlus4;
        o_Inst    <= i_PgmInst;
    end

endmodule
