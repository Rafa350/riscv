module StageIF
#(
    parameter PC_WIDTH  = 32)  // Ampla de adressa del bus d'instruccions
(
    // Senyals de control.
    input  logic                i_Clock,      // Clock
    input  logic                i_Reset,      // Reset    
    
    // Senyals de control de la memoria de programa.
    input  logic [31:0]         i_PgmInst,    // Instruccio de programa
    output logic [PC_WIDTH-1:0] o_PgmAddr,    // Adressa de programa

    // Senyals d'entrada de les etapes posteriors.
    input  logic [PC_WIDTH-1:0] i_PCNext,     // El nou PC
    
    // Senyals de sortida per la seguent etapa.
    output logic [31:0] o_Inst,                      // Instruccio    
    output logic [PC_WIDTH-1:0] o_PC);        // PC


    // ------------------------------------------------------------------------
    // Control del PC
    // ------------------------------------------------------------------------
        
    assign o_PgmAddr = o_PC; 
    assign o_Inst = i_PgmInst;
    
    always_ff @(posedge i_Clock)
        o_PC <= i_Reset ? 0 : i_PCNext;
    
endmodule
