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
    input  logic                       i_Clock,       // Clock
    input  logic                       i_Reset,       // Reset

    input  logic [DATA_DBUS_WIDTH-1:0] i_MemRdData,   // Dades de lectura de la memoria
    output logic [DATA_DBUS_WIDTH-1:0] o_MemWrData,   // Dades d'escriptura de la memoria
    output logic [ADDR_DBUS_WIDTH-1:0] o_MemAddr,     // Adressa de memoria per lectura/escriptura
    output logic                       o_MemWrEnable, // Habilita l'escriptura en la memoria

    input  logic [DATA_IBUS_WIDTH-1:0] i_PgmInst,     // Instruccio
    output logic [ADDR_IBUS_WIDTH-1:0] o_PgmAddr);    // Addressa de la instruccio

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
        inst_rs      = i_PgmInst[25:21];
        inst_rt      = i_PgmInst[20:16];
        inst_rd      = i_PgmInst[15:11];
        inst_sh      = i_PgmInst[10:6];
        inst_op      = InstOp'(i_PgmInst[31:26]);
        inst_fn      = InstFn'(i_PgmInst[5:0]);
        inst_imm16   = i_PgmInst[15:0];
        inst_imm16sx = {{16{inst_imm16[15]}}, inst_imm16};
        inst_imm26   = i_PgmInst[25:0];
    end

    // Control del datapath
    //
    AluOp ctrl_alu_op;      // Operacio de la ALU
    logic Ctrl_RegWrEnable; // Autoritza escriptura del regisres
    logic Ctrl_MemWrEnable; // Autoritza escritura en memoria
    logic Ctrl_IsBranch;    // Indica salt condicional
    logic Ctrl_IsJump;      // Indica salt
    logic ctrl_reg_dst_sel; // Selector del registre d'escriptura
    logic Ctrl_MemToReg;    // Selector del les dades d'esacriptura en el registre
    logic Ctrl_AluSrc;      // Seleccio de la entrada 2 de la ALU
    controller Ctrl (
        .i_Clock      (i_Clock),
        .i_Reset      (i_Reset),
        .i_inst_op    (inst_op),
        .i_inst_fn    (inst_fn),
        .o_AluControl (ctrl_alu_op),
        .o_mem_we     (Ctrl_MemWrEnable),
        .o_reg_we     (Ctrl_RegWrEnable),
        .o_AluSrc     (Ctrl_AluSrc),
        .o_RegDst     (ctrl_reg_dst_sel),
        .o_MemToReg   (Ctrl_MemToReg),
        .o_is_branch  (Ctrl_IsBranch),
        .o_is_jump    (Ctrl_IsJump)); 

    // Compara els valors del registre per decidir els salta condicionals
    //
    logic Comp_EQ; // Indica A == B
    Comparer #(
        .WIDTH (DATA_DBUS_WIDTH))
    Comp (
        .i_InputA (RegBlock_RdDataA),
        .i_InputB (RegBlock_RdDataB),
        .o_EQ     (Comp_EQ));


    // Bloc de registres
    //
    logic [DATA_DBUS_WIDTH-1:0] RegBlock_RdDataA, // Dades de lectura A
                                RegBlock_RdDataB; // Dades de lectura B
    RegBlock #(
        .DATA_WIDTH  (DATA_DBUS_WIDTH),
        .ADDR_WIDTH  (INDEX_WIDTH))
    RegBlock (
        .i_Clock    (i_Clock),
        .i_Reset    (i_Reset),
        .i_WrAddr   (Sel2_Output),
        .i_WrData   (Sel3_Output),
        .i_WrEnable (Ctrl_RegWrEnable),
        .i_RdAddrA  (inst_rs),
        .o_RdDataA  (RegBlock_RdDataA),
        .i_RdAddrB  (inst_rt),
        .o_RdDataB  (RegBlock_RdDataB));


    // Selecciona les dades d'entrada B de la ALU
    //
    logic [DATA_DBUS_WIDTH-1:0] Sel1_Output;   
    Mux2To1 #(
        .WIDTH  (DATA_DBUS_WIDTH))
    Sel1 (
        .i_Select (Ctrl_AluSrc),
        .i_Input0 (RegBlock_RdDataB),
        .i_Input1 (inst_imm16sx),
        .o_Output (Sel1_Output));

    // Selecciona el registre RT o RD de la instruccio
    //
    logic [INDEX_WIDTH-1:0] Sel2_Output;  
    Mux2To1 #(
        .WIDTH  (INDEX_WIDTH))
    Sel2 (
        .i_Select (ctrl_reg_dst_sel),
        .i_Input0 (inst_rt),
        .i_Input1 (inst_rd),
        .o_Output (Sel2_Output));

    // Selecciona les dades per escriure en el registre
    //
    logic [DATA_DBUS_WIDTH-1:0] Sel3_Output;  
    Mux2To1 #(
        .WIDTH  (DATA_DBUS_WIDTH))
    Sel3 (
        .i_Select (Ctrl_MemToReg),
        .i_Input0 (Alu_Output),
        .i_Input1 (i_MemRdData),
        .o_Output (Sel3_Output));

    // ALU
    //
    logic [DATA_DBUS_WIDTH-1:0] Alu_Output; 
    alu #(
        .WIDTH    (DATA_DBUS_WIDTH))
    Alu (
        .i_op     (ctrl_alu_op),
        .i_dataA  (RegBlock_RdDataA),
        .i_dataB  (Sel1_Output),
        .o_result (Alu_Output));

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
        .i_Select ({Ctrl_IsJump, Ctrl_IsBranch}),
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
        .i_Clock    (i_Clock),
        .i_Reset    (i_Reset),
        .i_WrEnable (1),
        .i_WrData   (pc_next),
        .o_RdData   (pc));


    // Interface amb la memoria RAM
    //
    always_comb begin
        o_MemAddr     = Alu_Output;
        o_MemWrEnable = Ctrl_MemWrEnable;
        o_MemWrData   = RegBlock_RdDataB;
    end

    // Interface amb la memoria de programa
    //
    assign o_PgmAddr  = pc;

endmodule


