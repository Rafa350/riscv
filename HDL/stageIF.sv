module stageIF
#(
    parameter DATA_IBUS_WIDTH          = 32,             // Ampla de dades del bus d'instruccions
    parameter ADDR_IBUS_WIDTH          = 32)             // Ampla de adressa del bus d'instruccions
(
    // Senyals de control
    //
    input  logic                       i_clk,            // Clock
    input  logic                       i_rst,            // Reset    
    
    // Interface amb la memoria de programa
    //
    input  logic [DATA_IBUS_WIDTH-1:0] i_pgm_inst,       // Program instruction
    output logic [ADDR_IBUS_WIDTH-1:0] o_pgm_addr,       // Program address

    // Entrades del pipeline     
    //
    input  logic                       i_BranchEnable,   // Branch enable
    input  logic [ADDR_IBUS_WIDTH-1:0] i_BranchAddr,     // Branch address
    
    // Sortides del pipeline 
    //
    output logic [DATA_IBUS_WIDTH-1:0] o_Inst,           // Instruction
    output logic [ADDR_IBUS_WIDTH-1:0] o_PCPlus4);       // PC+4    
    
    // Senals internes
    //
    logic [DATA_IBUS_WIDTH-1:0] Inst;       // La instruccio actual
    logic [ADDR_IBUS_WIDTH-1:0] PC;         // El PC actual
    logic [ADDR_IBUS_WIDTH-1:0] PCPlus4;    // El PC de la seguent instruccio
    
    // Control d'acces a la memoria de programa
    //
    assign o_PgmAddr = PC; 
    assign Inst = i_PgmInst;
       
    // Evalua el contador de programa
    //
    assign PCPlus4 = PC + 4;
    always_ff @(posedge i_clk) begin
        case ({i_rst, i_BranchEnable})
            2'b00: PC <= PCPlus4;
            2'b01: PC <= i_BranchAddr;
            2'b10: PC <= 0;
            2'b11: PC <= 0;
        endcase
    end        
            
    // Actualitza els registres pipeline de sortida
    //
    always_ff @(posedge i_clk) begin
        o_PCPlus4 <= PCPlus4;
        o_Inst    <= Inst;
    end

endmodule
