// verilator lint_off PINMISSING 
// verilator lint_off IMPORTSTAR 
// verilator lint_off UNUSED

import types::*;


module cpu
#(
    parameter DATA_DBUS_WIDTH          = 32,
    parameter ADDR_DBUS_WIDTH          = 32,
    parameter DATA_IBUS_WIDTH          = 32,
    parameter ADDR_IBUS_WIDTH          = 32,
    parameter INDEX_WIDTH              = 5)
(
    input  logic                       i_clk,
    input  logic                       i_rst,
    
    input  logic [DATA_DBUS_WIDTH-1:0] i_mem_rd_data,
    output logic [DATA_DBUS_WIDTH-1:0] o_mem_wr_data,
    output logic [ADDR_DBUS_WIDTH-1:0] o_mem_addr,
    output logic                       o_mem_we,

    input  logic [DATA_IBUS_WIDTH-1:0] i_pgm_inst,
    output logic [ADDR_IBUS_WIDTH-1:0] o_pgm_addr);
    
    logic [ADDR_IBUS_WIDTH-1:0] pc_inc4;    // Contador de programa actualitzat
    logic branch;
      
    logic [INDEX_WIDTH-1:0] inst_rs;
    logic [INDEX_WIDTH-1:0] inst_rt;
    logic [INDEX_WIDTH-1:0] inst_rd;
    logic [4:0] inst_sh;
    logic [15:0] inst_imm16;
    logic [25:0] inst_imm26;
    InstOp inst_op;
    InstFn inst_fn;
    
    logic BranchRequest;

    logic regs_wr_index_selector;                // Selector del registre d'escriptura
    logic regs_wr_data_selector;                 // Selector del les dades d'esacriptura en el registre
    logic [DATA_DBUS_WIDTH-1:0] regs_rdataA;     // Dades de lectura A
    logic [DATA_DBUS_WIDTH-1:0] regs_rdataB;     // Dades de lectura B
    logic [DATA_DBUS_WIDTH-1:0] regs_wdata;      // Dades d'escriptura   
    logic [INDEX_WIDTH-1:0] regs_wr_index;       // Index del registre d'escriptura
    logic regs_we;                               // Autoritza escriptura del regisres
    
    logic mem_we;                                // Autoritza escritura en memoria
    
    AluOp alu_op;                                // Operacio de la ALU
    logic alu_data2_selector;                    // Seleccio de la entrada 2 de la ALU
    logic [DATA_DBUS_WIDTH-1:0] alu_dataB;       // Dades B
    logic [DATA_DBUS_WIDTH-1:0] alu_result;      // Resultat
    
    
    function logic [DATA_DBUS_WIDTH-1:0] signx(logic [(DATA_DBUS_WIDTH/2)-1:0] in);   
        return {{DATA_DBUS_WIDTH/2{in[15]}}, in};        
    endfunction
    
    //function logic [DATA_WIDTH-1:0] shift_2left(logic [DATA_WIDTH-1:0] in);
    //    return {in[DATA_WIDTH-1:2], 2'b00};
    //endfunction
                   
    // Separacio de la inmstruccio en blocs
    //
    assign inst_rs = i_pgm_inst[25:21];
    assign inst_rt = i_pgm_inst[20:16];
    assign inst_rd = i_pgm_inst[15:11];
    assign inst_sh = i_pgm_inst[10:6];
    assign inst_op = InstOp'(i_pgm_inst[31:26]);
    assign inst_fn = InstFn'(i_pgm_inst[5:0]);
    assign inst_imm16 = i_pgm_inst[15:0];

    // Control
    controller controller(
        .i_clk           (i_clk),
        .i_rst           (i_rst),
        .i_inst_op       (inst_op),
        .i_inst_fn       (inst_fn),
        .o_AluControl    (alu_op),
        .o_MemWrite      (mem_we),
        .o_RegWrite      (regs_we),
        .o_AluSrc        (alu_data2_selector),
        .o_RegDst        (regs_wr_index_selector),
        .o_MemToReg      (regs_wr_data_selector),
        .o_BranchRequest (BranchRequest));
        
    // Bloc de registres
    regfile #(
        .DATA_WIDTH  (DATA_DBUS_WIDTH),
        .REG_WIDTH   (INDEX_WIDTH))
    regs (
        .i_clk       (i_clk),
        .i_rst       (i_rst),
        .i_wr_reg    (regs_wr_index),
        .i_wr_data   (regs_wdata),
        .i_we        (regs_we),
        .i_rd_reg_A  (inst_rs),
        .o_rd_data_A (regs_rdataA),
        .i_rd_reg_B  (inst_rt),
        .o_rd_data_B (regs_rdataB));
    
    // ALU data2 selector
    mux2 #(
        .WIDTH  (DATA_DBUS_WIDTH))
    alu_data2_mux (
        .i_sel  (alu_data2_selector),
        .i_in_0 (regs_rdataB),
        .i_in_1 (signx(inst_imm16)),
        .o_out  (alu_dataB));
        
    // Destination register selector
    //
    mux2 #(
        .WIDTH  (INDEX_WIDTH))
    regs_wd_index_mux (
        .i_sel  (regs_wr_index_selector),
        .i_in_0 (inst_rt),
        .i_in_1 (inst_rd),
        .o_out  (regs_wr_index));
        
    // Destination data selector
    //
    mux2 #(
        .WIDTH  (DATA_DBUS_WIDTH))
    reg_rd_data_mux (
        .i_sel  (regs_wr_data_selector),
        .i_in_0 (alu_result),
        .i_in_1 (i_mem_rd_data),
        .o_out  (regs_wdata));
        
    // ALU
    alu #(
        .WIDTH    (DATA_DBUS_WIDTH))
    alu (
        .i_op     (alu_op),
        .i_data_A (regs_rdataA),
        .i_data_B (alu_dataB),
        .o_result (alu_result));        

    // Program counter
    assign pc_inc4 = o_pgm_addr + 4;
    always_ff @(posedge i_clk) begin
        if (i_rst)
            o_pgm_addr <= 0;
        else
            o_pgm_addr <= pc_inc4;
    end
    
    // Memoria
    //
    assign o_mem_addr = alu_result;
    assign o_mem_we = mem_we;
    assign o_mem_wr_data = regs_rdataB;
          
endmodule


