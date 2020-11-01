module stageF
#(
    parameter ADDR_WIDTH = 32)
(
    input  logic                  i_clk,       // Clock
    input  logic                  i_rst,       // Reset
    
    input  logic                  i_pc_je,     // Jump enable
    input  logic [ADDR_WIDTH-1:0] i_pc_jaddr,  // Jump address
    
    output logic [ADDR_WIDTH-1:0] o_pc_next,   // Next PC
    output logic [ADDR_WIDTH-1:0] o_inst);     // Instruction
    
    logic [ADDR_WIDTH-1:0] pc;
    logic [ADDR_WIDTH-1:0] pc_next;
    logic [ADDR_WIDTH-1:0] inst;
    
    assign pc_next = pc + 4;
    
    // Memoria del programa
    //
    pgm #(
        .INST_WIDTH(32),
        .ADDR_WIDTH(ADDR_WIDTH));
    pgm(
        i_addr(pc),
        o_inst(inst));

    // Actualitza el contador de progama
    //
    always_ff @(posedge i_clk)
        if (i_rst)
            pc <= 0;
        else 
            pc <= i_branch ? i_pc_jaddr : pc_next;
            
    // Actualitza registre pipeline
    //
    always_ff @(posedge i_clk) begin
        o_pc_next <= pc_next;
        o_inst <= inst;
    end

endmodule
