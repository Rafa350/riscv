module stageD(

    input  logic        i_clk,
    input  logic        i_rst,
    
    input  logic [31:0] i_inst,
    input  logic [31:0] i_pc_next,
    
    input  logic [4:0]  i_reg_wreg,
    input  logic [31:0] i_reg_wdata,
    
    output logic [31:0] o_dataA,
    output logic [31:0] o_dataB,
    output logic [4:0]  o_rt,
    output logic [4:0]  o_rd,
    
    output logic [31:0] o_pc_next);
    
    logic [31:0] dataA;
    logic [31:0] dataB;
    
    regfile #(
        .DATA_WIDTH(31),
        .REG_WIDTH(5)
    regfile (
        .i_clk(i_clk),
        .i_rst(i_rst),
        .i_rregA(i_inst[25:21]),
        .i_rregB(i_inst[20:16]),
        .i_wreg(i_reg_wreg),
        .i_wdata(i_reg_wdata),
        .o_rdataA(dataA),
        .o_rdataB(dataB));

    always_ff @(posedge i_clk) begin
        o_dataA <= dataA;
        o_dataB <= dataB;
        o_rt = i_inst[20:16];
        o_rd = i_inst[15:11];
        o_pc_next <= i_pc_next;
    end
    
endmodule