// verilator lint_off IMPORTSTAR
// verilator lint_off PINMISSING
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

    input  logic [DATA_DBUS_WIDTH-1:0] i_mem_rdata,
    output logic [DATA_DBUS_WIDTH-1:0] o_mem_wdata,
    output logic [ADDR_DBUS_WIDTH-1:0] o_mem_addr,
    output logic                       o_mem_we,

    input  logic [DATA_IBUS_WIDTH-1:0] i_pgm_inst,
    output logic [ADDR_IBUS_WIDTH-1:0] o_pgm_addr);

    // Control de PC
    //
    logic [ADDR_IBUS_WIDTH-1:0] pc;         // Valor actual del PC
    logic [ADDR_IBUS_WIDTH-1:0] pc_next;    // Valor per actualitzar PCº
    logic                       pc_we;      // Habilita escriptura en PC
    logic [ADDR_IBUS_WIDTH-1:0] pc_inc4;    // Valor incrementat (+4)
    logic [ADDR_IBUS_WIDTH-1:0] pc_branch;  // Valor per bifurcacio
    logic [ADDR_IBUS_WIDTH-1:0] pc_jump;    // Valor per salt

    // Instruccio
    //
    logic [ADDR_IBUS_WIDTH-1:0] inst;
    logic [INDEX_WIDTH-1:0] inst_rs;
    logic [INDEX_WIDTH-1:0] inst_rt;
    logic [INDEX_WIDTH-1:0] inst_rd;
    logic [4:0] inst_sh;
    logic [15:0] inst_imm16;
    logic [DATA_DBUS_WIDTH-1:0] inst_imm16sx;
    logic [25:0] inst_imm26;
    InstOp inst_op;
    InstFn inst_fn;

    // Control del datapath
    //
    logic regs_wr_index_selector;                // Selector del registre d'escriptura
    logic regs_wr_data_selector;                 // Selector del les dades d'esacriptura en el registre
    logic [DATA_DBUS_WIDTH-1:0] regs_rdataA;     // Dades de lectura A
    logic [DATA_DBUS_WIDTH-1:0] regs_rdataB;     // Dades de lectura B
    logic [DATA_DBUS_WIDTH-1:0] regs_wdata;      // Dades d'escriptura
    logic [INDEX_WIDTH-1:0] regs_waddr;          // Index del registre d'escriptura
    logic regs_we;                               // Autoritza escriptura del regisres
    logic is_branch;                             // Indica salt condicional
    logic is_jump;                               // Indica salt
    logic is_eq;                                 // Indica A == B
    logic mem_we;                                // Autoritza escritura en memoria
    AluOp alu_op;                                // Operacio de la ALU
    logic alu_data2_selector;                    // Seleccio de la entrada 2 de la ALU
    logic [DATA_DBUS_WIDTH-1:0] alu_dataB;       // Dades B
    logic [DATA_DBUS_WIDTH-1:0] alu_result;      // Resultat


    // Separacio de la instruccio en blocs
    //
    always_comb begin
        inst_rs      = inst[25:21];
        inst_rt      = inst[20:16];
        inst_rd      = inst[15:11];
        inst_sh      = inst[10:6];
        inst_op      = InstOp'(inst[31:26]);
        inst_fn      = InstFn'(inst[5:0]);
        inst_imm16   = inst[15:0];
        inst_imm16sx = {{16{inst[15]}}, inst[15:0]};
        inst_imm26   = inst[25:0];
    end

    // Control
    //
    controller controller(
        .i_clk        (i_clk),
        .i_rst        (i_rst),
        .i_inst_op    (inst_op),
        .i_inst_fn    (inst_fn),
        .o_AluControl (alu_op),
        .o_MemWrite   (mem_we),
        .o_RegWrite   (regs_we),
        .o_AluSrc     (alu_data2_selector),
        .o_RegDst     (regs_wr_index_selector),
        .o_MemToReg   (regs_wr_data_selector),
        .o_is_branch  (is_branch),
        .o_is_jump    (is_jump));

    // Comparador
    //
    comparer #(
        .WIDTH (DATA_DBUS_WIDTH))
    comparer (
        .i_inA (regs_rdataA),
        .i_inB (regs_rdataB),
        .o_eq  (is_eq));

    // Bloc de registres
    regfile #(
        .DATA_WIDTH  (DATA_DBUS_WIDTH),
        .ADDR_WIDTH  (INDEX_WIDTH))
    regs (
        .i_clk    (i_clk),
        .i_rst    (i_rst),
        .i_waddr  (regs_waddr),
        .i_wdata  (regs_wdata),
        .i_we     (regs_we),
        .i_raddrA (inst_rs),
        .o_rdataA (regs_rdataA),
        .i_raddrB (inst_rt),
        .o_rdataB (regs_rdataB));

    // ALU data2 selector
    mux2 #(
        .WIDTH  (DATA_DBUS_WIDTH))
    alu_data2_mux (
        .i_sel (alu_data2_selector),
        .i_in0 (regs_rdataB),
        .i_in1 (inst_imm16sx),
        .o_out (alu_dataB));

    // Destination register selector
    //
    mux2 #(
        .WIDTH  (INDEX_WIDTH))
    regs_wd_index_mux (
        .i_sel (regs_wr_index_selector),
        .i_in0 (inst_rt),
        .i_in1 (inst_rd),
        .o_out (regs_waddr));

    // Destination data selector
    //
    mux2 #(
        .WIDTH  (DATA_DBUS_WIDTH))
    reg_rd_data_mux (
        .i_sel  (regs_wr_data_selector),
        .i_in0  (alu_result),
        .i_in1  (i_mem_rdata),
        .o_out  (regs_wdata));

    // ALU
    //
    alu #(
        .WIDTH    (DATA_DBUS_WIDTH))
    alu (
        .i_op     (alu_op),
        .i_dataA  (regs_rdataA),
        .i_dataB  (alu_dataB),
        .o_result (alu_result));

    // Evalua pc_inc4
    //
    half_adder #(
        .WIDTH (ADDR_IBUS_WIDTH))
    pc_inc4_adder (
        .i_inA (pc),
        .i_inB (4),
        .o_out (pc_inc4));

    // Evalua pc_branch
    //
    half_adder #(
        .WIDTH (ADDR_IBUS_WIDTH))
    pc_branch_adder (
        .i_inA (pc_inc4),
        .i_inB ({inst_imm16sx[29:0], 2'b00}),
        .o_out (pc_branch));

    // Evalua pc_jump
    //
    assign pc_jump = {pc[31:28], inst_imm26, 2'b00};

    // Selecciona el nou valor del contador de programa
    //
    mux4 #(
        .WIDTH (ADDR_IBUS_WIDTH))
    pc_source_mux (
        .i_sel ({is_jump, is_branch}),
        .i_in0 (pc_inc4),
        .i_in1 (pc_branch),
        .i_in2 (pc_jump),
        .i_in3 (pc_inc4),
        .o_out (pc_next));

    // Registre del contador de programa
    //
    register #(
        .WIDTH (ADDR_IBUS_WIDTH),
        .INIT  (0))
    pc_register (
        .i_clk   (i_clk),
        .i_rst   (i_rst),
        .i_we    (1),
        .i_wdata (pc_next),
        .o_rdata (pc));

    // Memoria RAM
    //
    always_comb begin
        o_mem_addr  = alu_result;
        o_mem_we    = mem_we;
        o_mem_wdata = regs_rdataB;
    end

    // Memoria de programa
    //
    always_comb begin
        o_pgm_addr  = pc;
        inst = i_pgm_inst;
    end

endmodule


