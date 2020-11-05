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
    output logic [DATA_IBUS_WIDTH-1:0] o_inst,           // Instruction
    output logic [ADDR_IBUS_WIDTH-1:0] o_pc_plus4);      // PC+4    
    
    // Senals internes
    //
    logic [DATA_IBUS_WIDTH-1:0] inst;       // La instruccio actual
    logic [ADDR_IBUS_WIDTH-1:0] pc;         // El PC actual
    logic [ADDR_IBUS_WIDTH-1:0] pc_plus4;   // El PC de la seguent instruccio
    
    // Acces a la memoria de programa
    //
    always_comb begin
        o_pgm_addr = pc; 
        inst = i_pgm_inst;
    end
       
    // Contador de programa
    //
    assign pc_plus4 = pc + 4;               
    always_ff @(posedge i_clk) begin
        case ({i_rst, i_BranchEnable})
            2'b00: pc <= pc_plus4;
            2'b01: pc <= i_BranchAddr;
            2'b10: pc <= 0;
            2'b11: pc <= 0;
        endcase
    end        
            
    // Registres pipeline de sortida
    //
    always_ff @(posedge i_clk) begin
        o_pc_plus4 <= pc_plus4;
        o_inst     <= inst;
    end

endmodule
