// verilator lint_off PINMISSING 
// verilator lint_off IMPORTSTAR 
 

import types::*;


module cpu
#(
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 32,
    parameter INDEX_WIDTH = 5,
    parameter INST_WIDTH = 32,
    parameter PC_WIDTH = 32)
(
    input logic i_clk,
    input logic i_rst,
    
    input logic [DATA_WIDTH-1:0] i_mem_rd_data,
    output logic [DATA_WIDTH-1:0] o_mem_wr_data,
    output logic [ADDR_WIDTH-1:0] o_mem_addr,
    output logic o_mem_wr_enable,

    input logic [INST_WIDTH-1:0] i_inst,
    output logic [PC_WIDTH-1:0] o_pc);
    
    logic [PC_WIDTH-1:0] pc_next;           // Contador de programa actualitzat
      
    logic regs_wr_index_selector;           // Selector del registre d'escriptura
    logic regs_wr_data_selector;            // Selector del les dades d'esacriptura en el registre
    logic [DATA_WIDTH-1:0] regs_rd_data1;   // Dades de lectura 1
    logic [DATA_WIDTH-1:0] regs_rd_data2;   // Dades de lectura 2
    logic [DATA_WIDTH-1:0] regs_wr_data;    // Dades d'escriptura   
    logic [INDEX_WIDTH-1:0] regs_wr_index;  // Index del registre d'escriptura
    logic regs_wr_enable;                   // Autoritza escriptura del regisres
    
    logic mem_wr_enable;                    // Autoritza escritura en memoria
    
    AluOp alu_op;                           // Operacio de la ALU
    logic alu_data2_selector;               // Seleccio de la entrada 2 de la ALU
    logic [DATA_WIDTH-1:0] alu_data2;       // Dades 2
    logic [DATA_WIDTH-1:0] alu_result;      // Resultat
    
    
    function logic [DATA_WIDTH-1:0] signx(logic [(DATA_WIDTH/2)-1:0] in);   
        return {{DATA_WIDTH/2{in[15]}}, in};        
    endfunction
    
    //function logic [DATA_WIDTH-1:0] shift_2left(logic [DATA_WIDTH-1:0] in);
    //    return {in[DATA_WIDTH-1:2], 2'b00};
    //endfunction
                   
    //logic [INDEX_WIDTH-1:0] inst_rs;
    
    //logic [INDEX_WIDTH-1:0] inst_rt;
    
    //logic [INDEX_WIDTH-1:0] inst_rd;
    
    InstOp inst_op;
    assign inst_op = InstOp'(i_inst[31:26]);
    
    InstFn inst_fn;
    assign inst_fn = InstFn'(i_inst[5:0]);

    // Control
    controller controller(
        .i_clk(i_clk),
        .i_rst(i_rst),
        .i_inst_op(inst_op),
        .i_inst_fn(inst_fn),
        .o_alu_op(alu_op),
        .o_mem_wr_enable(mem_wr_enable),
        .o_regs_wr_enable(regs_wr_enable),
        .o_alu_data2_selector(alu_data2_selector),
        .o_regs_wr_index_selector(regs_wr_index_selector),
        .o_regs_wr_data_selector(regs_wr_data_selector));
        
    // Bloc de registres
    regfile #(
        .DATA_WIDTH(DATA_WIDTH),
        .REG_WIDTH(INDEX_WIDTH))
    regfile (
        .i_clk(i_clk),
        .i_rst(i_rst),
        .i_wreg(regs_wr_index),
        .i_wdata(regs_wr_data),
        .i_we(regs_wr_enable),
        .i_rregA(i_inst[25:21]),
        .o_rdataA(regs_rd_data1),
        .i_rregB(i_inst[20:16]),
        .o_rdataB(regs_rd_data2));
    
    // ALU data2 selector
    mux2 #(
        .WIDTH(DATA_WIDTH))
    alu_data2_mux (
        .i_sel(alu_data2_selector),
        .i_in0(regs_rd_data2),
        .i_in1(signx(i_inst[(DATA_WIDTH/2)-1:0])),
        .o_out(alu_data2));
        
    // Destination register selector
    //
    mux2 #(
        .WIDTH(INDEX_WIDTH))
    regs_wd_index_mux (
        .i_sel(regs_wr_index_selector),
        .i_in0(i_inst[20:16]),
        .i_in1(i_inst[15:11]),
        .o_out(regs_wr_index));
        
    // Destination data selector
    //
    mux2 #(
        .WIDTH(DATA_WIDTH))
    reg_rd_data_mux (
        .i_sel(regs_wr_data_selector),
        .i_in0(alu_result),
        .i_in1(i_mem_rd_data),
        .o_out(regs_wr_data));
        
    // ALU
    alu #(
        .DATA_WIDTH(DATA_WIDTH))
    alu (
        .i_op(alu_op),
        .i_dataA(regs_rd_data1),
        .i_dataB(alu_data2),
        .o_result(alu_result));        

    // Program counter
    assign pc_next = o_pc + 1;
    always_ff @(posedge i_clk) begin
        if (i_rst)
            o_pc <= 0;
        else
            o_pc <= pc_next;
    end
    
    // Memoria
    //
    assign o_mem_addr = alu_result;
    assign o_mem_wr_enable = mem_wr_enable;
    assign o_mem_wr_data = regs_rd_data2;
          
endmodule


