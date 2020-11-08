module stageIF
#(
    parameter DATA_IBUS_WIDTH          = 32,        // Ampla de dades del bus d'instruccions
    parameter ADDR_IBUS_WIDTH          = 32)        // Ampla de adressa del bus d'instruccions
(
    // Senyals de control
    //
    input  logic                       i_clk,       // Clock
    input  logic                       i_rst,       // Reset    
    
    // Interface amb la memoria de programa
    //
    input  logic [DATA_IBUS_WIDTH-1:0] i_pgm_inst,  // Instruccio de programa
    output logic [ADDR_IBUS_WIDTH-1:0] o_pgm_addr,  // Adressa del programa

    // Entrades del pipeline     
    //
    input  logic                       i_pc_src,    // Seleccio del seguent PC
    input  logic [ADDR_IBUS_WIDTH-1:0] i_pc_branch, // Adressa de salt
    
    // Sortides del pipeline 
    //
    output logic [DATA_IBUS_WIDTH-1:0] o_inst,      // Instruccio actual
    output logic [ADDR_IBUS_WIDTH-1:0] o_pc_plus4); // Adressa de la propera instruccio
    
    // Senals internes
    //
    logic [DATA_IBUS_WIDTH-1:0] inst;       // La instruccio actual
    logic [ADDR_IBUS_WIDTH-1:0] pc;         // El PC actual
    logic [ADDR_IBUS_WIDTH-1:0] pc_plus4;   // El PC de la seguent instruccio
    logic [ADDR_IBUS_WIDTH-1:0] pc_next;    // El nou valor del PC
    
    
    // Gestio de la memoria de programa
    //
    always_comb begin
        o_pgm_addr = pc; 
        inst = i_pgm_inst;
    end
       
       
    // Gestio del contador de programa
    //
    assign pc_plus4 = pc + 4;     
    assign pc_next = i_pc_src ? i_pc_branch : pc_plus4;

    register #(
        .WIDTH (ADDR_IBUS_WIDTH),
        .INIT  (0))
    pc_register (
        .i_clk   (i_clk),
        .i_rst   (i_rst),
        .i_we    (1),
        .i_wdata (pc_next),
        .o_rdata (pc));
        
            
    // Registres pipeline de sortida
    //
    always_ff @(posedge i_clk) begin
        o_pc_plus4 <= pc_plus4;
        o_inst     <= inst;
    end

endmodule
