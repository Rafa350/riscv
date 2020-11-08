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
    input  logic                       i_clk,       // Clock
    input  logic                       i_rst,       // Reset

    input  logic [DATA_DBUS_WIDTH-1:0] i_mem_rdata, // Dades de lectura de la memoria
    output logic [DATA_DBUS_WIDTH-1:0] o_mem_wdata, // Dades d'escriptura de la memoria
    output logic [ADDR_DBUS_WIDTH-1:0] o_mem_addr,  // Adressa de memoria per lectura/escriptura
    output logic                       o_mem_we,    // Habilita l'escriptura en la memoria

    input  logic [DATA_IBUS_WIDTH-1:0] i_pgm_inst,  // Instruccio
    output logic [ADDR_IBUS_WIDTH-1:0] o_pgm_addr); // Addressa de la instruccio

    // Control de PC
    //
    logic [ADDR_IBUS_WIDTH-1:0] pc;        // Valor actual del PC
    logic [ADDR_IBUS_WIDTH-1:0] pc_next;   // Valor per actualitzar PCº
    logic                       pc_we;     // Habilita escriptura en PC
    logic [ADDR_IBUS_WIDTH-1:0] pc_inc4;   // Valor incrementat (+4)
    logic [ADDR_IBUS_WIDTH-1:0] pc_branch; // Valor per bifurcacio
    logic [ADDR_IBUS_WIDTH-1:0] pc_jump;   // Valor per salt
   
    // Separacio de la instruccio en blocs
    //
    logic [INDEX_WIDTH-1:0]     inst_rs;      // RS
    logic [INDEX_WIDTH-1:0]     inst_rt;      // RT
    logic [INDEX_WIDTH-1:0]     inst_rd;      // RD
    logic [4:0]                 inst_sh;      // Nombre de bits per desplaçar
    logic [15:0]                inst_imm16;   // Valor inmediat 16 bits
    logic [DATA_DBUS_WIDTH-1:0] inst_imm16sx; // Valor inmediat 16 bits amb expansio de signe a 32 bits
    logic [25:0]                inst_imm26;   // Valor inmediat 26 bitsº
    InstOp                      inst_op;      // Codi d'operacio
    InstFn                      inst_fn;      // Codi de funcio per intruccions Type-R
    always_comb begin
        inst_rs      = i_pgm_inst[25:21];
        inst_rt      = i_pgm_inst[20:16];
        inst_rd      = i_pgm_inst[15:11];
        inst_sh      = i_pgm_inst[10:6];
        inst_op      = InstOp'(i_pgm_inst[31:26]);
        inst_fn      = InstFn'(i_pgm_inst[5:0]);
        inst_imm16   = i_pgm_inst[15:0];
        inst_imm16sx = {{16{inst_imm16[15]}}, inst_imm16};
        inst_imm26   = i_pgm_inst[25:0];
    end

    // Control del datapath
    //
    AluOp ctrl_alu_op;         // Operacio de la ALU
    logic ctrl_reg_we;         // Autoritza escriptura del regisres
    logic ctrl_mem_we;         // Autoritza escritura en memoria
    logic ctrl_is_branch;      // Indica salt condicional
    logic ctrl_is_jump;        // Indica salt
    logic ctrl_reg_dst_sel;    // Selector del registre d'escriptura
    logic ctrl_mem_to_reg_sel; // Selector del les dades d'esacriptura en el registre
    logic ctrl_alu_src_sel;    // Seleccio de la entrada 2 de la ALU
    controller Ctrl (
        .i_clk        (i_clk),
        .i_rst        (i_rst),
        .i_inst_op    (inst_op),
        .i_inst_fn    (inst_fn),
        .o_AluControl (ctrl_alu_op),
        .o_mem_we     (ctrl_mem_we),
        .o_reg_we     (ctrl_reg_we),
        .o_AluSrc     (ctrl_alu_src_sel),
        .o_RegDst     (ctrl_reg_dst_sel),
        .o_MemToReg   (ctrl_mem_to_reg_sel),
        .o_is_branch  (ctrl_is_branch),
        .o_is_jump    (ctrl_is_jump)); 

    // Compara els valors del registre per decidir els salta condicionals
    //
    logic cmp_is_eq; // Indica A == B
    Comparer #(
        .WIDTH (DATA_DBUS_WIDTH))
    Comp (
        .i_InputA (regs_rdataA),
        .i_InputB (regs_rdataB),
        .o_EQ     (cmp_is_eq));


    // Bloc de registres
    //
    logic [DATA_DBUS_WIDTH-1:0] regs_rdataA, // Dades de lectura A
                                regs_rdataB; // Dades de lectura B
    RegBlock #(
        .DATA_WIDTH  (DATA_DBUS_WIDTH),
        .ADDR_WIDTH  (INDEX_WIDTH))
    RegBlock (
        .i_Clock    (i_clk),
        .i_Reset    (i_rst),
        .i_WrAddr   (sel2_out),
        .i_WrData   (sel3_out),
        .i_WrEnable (ctrl_reg_we),
        .i_RdAddrA  (inst_rs),
        .o_RdDataA  (regs_rdataA),
        .i_RdAddrB  (inst_rt),
        .o_RdDataB  (regs_rdataB));


    // Selecciona les dades d'entrada B de la ALU
    //
    logic [DATA_DBUS_WIDTH-1:0] sel1_out;   
    Mux2To1 #(
        .WIDTH  (DATA_DBUS_WIDTH))
    Sel1 (
        .i_Select (ctrl_alu_src_sel),
        .i_Input0 (regs_rdataB),
        .i_Input1 (inst_imm16sx),
        .o_Output (sel1_out));

    // Selecciona el registre RT o RD de la instruccio
    //
    logic [INDEX_WIDTH-1:0] sel2_out;  
    Mux2To1 #(
        .WIDTH  (INDEX_WIDTH))
    Sel2 (
        .i_Select (ctrl_reg_dst_sel),
        .i_Input0 (inst_rt),
        .i_Input1 (inst_rd),
        .o_Output (sel2_out));

    // Selecciona les dades per escriure en el registre
    //
    logic [DATA_DBUS_WIDTH-1:0] sel3_out;  
    Mux2To1 #(
        .WIDTH  (DATA_DBUS_WIDTH))
    Sel3 (
        .i_Select (ctrl_mem_to_reg_sel),
        .i_Input0 (alu_result),
        .i_Input1 (i_mem_rdata),
        .o_Output (sel3_out));

    // ALU
    //
    logic [DATA_DBUS_WIDTH-1:0] alu_result; 
    alu #(
        .WIDTH    (DATA_DBUS_WIDTH))
    alu (
        .i_op     (ctrl_alu_op),
        .i_dataA  (regs_rdataA),
        .i_dataB  (sel1_out),
        .o_result (alu_result));

    // Evalua pc_inc4
    //
    HalfAdder #(
        .WIDTH (ADDR_IBUS_WIDTH))
    pc_inc4_adder (
        .i_OperandA (pc),
        .i_OperandB (4),
        .o_Result   (pc_inc4));

    // Evalua pc_branch
    //
    HalfAdder #(
        .WIDTH (ADDR_IBUS_WIDTH))
    pc_branch_adder (
        .i_OperandA (pc_inc4),
        .i_OperandB ({inst_imm16sx[29:0], 2'b00}),
        .o_Result   (pc_branch));

    // Evalua pc_jump
    //
    assign pc_jump = {pc[31:28], inst_imm26, 2'b00};

    // Selecciona el nou valor del contador de programa
    //
    Mux4To1 #(
        .WIDTH (ADDR_IBUS_WIDTH))
    pc_source_mux (
        .i_Select ({ctrl_is_jump, ctrl_is_branch}),
        .i_Input0 (pc_inc4),
        .i_Input1 (pc_branch),
        .i_Input2 (pc_jump),
        .i_Input3 (pc_inc4),
        .o_Output (pc_next));

    // Registre del contador de programa
    //
    Register #(
        .WIDTH (ADDR_IBUS_WIDTH),
        .INIT  (0))
    pc_register (
        .i_Clock    (i_clk),
        .i_Reset    (i_rst),
        .i_WrEnable (1),
        .i_WrData   (pc_next),
        .o_RdData   (pc));

    // Interface amb la emoria RAM
    //
    always_comb begin
        o_mem_addr  = alu_result;
        o_mem_we    = ctrl_mem_we;
        o_mem_wdata = regs_rdataB;
    end

    // Interface amb la memoria de programa
    //
    assign o_pgm_addr  = pc;

endmodule


