// verilator lint_off IMPORTSTAR
// verilator lint_off PINMISSING
// verilator lint_off UNUSED

import types::*;


module ProcessorSC
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
    logic [ADDR_IBUS_WIDTH-1:0] PC;       // Valor actual del PC
    logic [ADDR_IBUS_WIDTH-1:0] PCNext;   // Valor per actualitzar PC
    logic [ADDR_IBUS_WIDTH-1:0] PCPlus4;  // Valor incrementat (+4)
    logic [ADDR_IBUS_WIDTH-1:0] PCBranch; // Valor per bifurcacio
    logic [ADDR_IBUS_WIDTH-1:0] PCJump;   // Valor per salt
   
    // Separacio de la instruccio en blocs
    //
    logic [INDEX_WIDTH-1:0]     InstRS;      // RS
    logic [INDEX_WIDTH-1:0]     InstRT;      // RT
    logic [INDEX_WIDTH-1:0]     InstRD;      // RD
    logic [4:0]                 InstSH;      // Nombre de bits per desplaçar
    logic [15:0]                InstIMM16;   // Valor inmediat 16 bits
    logic [DATA_DBUS_WIDTH-1:0] InstIMM16SX; // Valor inmediat 16 bits amb expansio de signe a 32 bits
    logic [25:0]                InstIMM26;   // Valor inmediat 26 bits
    InstOp                      InstOP;      // Codi d'operacio
    InstFn                      InstFN;      // Codi de funcio per intruccions Type-R
    always_comb begin
        InstRS      = i_PgmInst[25:21];
        InstRT      = i_PgmInst[20:16];
        InstRD      = i_PgmInst[15:11];
        InstSH      = i_PgmInst[10:6];
        InstOP      = InstOp'(i_PgmInst[31:26]);
        InstFN      = InstFn'(i_PgmInst[5:0]);
        InstIMM16   = i_PgmInst[15:0];
        InstIMM16SX = {{16{InstIMM16[15]}}, InstIMM16};
        InstIMM26   = i_PgmInst[25:0];
    end


    // Control del datapath
    //
    AluOp Ctrl_AluControl;  // Operacio de la ALU
    logic Ctrl_RegWrEnable; // Autoritza escriptura del regisres
    logic Ctrl_MemWrEnable; // Autoritza escritura en memoria
    logic Ctrl_IsBranch;    // Indica salt condicional
    logic Ctrl_IsJump;      // Indica salt
    logic Ctrl_RegDst;      // Selector del registre d'escriptura
    logic Ctrl_MemToReg;    // Selector del les dades d'esacriptura en el registre
    logic Ctrl_AluSrcB;     // Seleccio de la entrada 2 de la ALU
    Controller Ctrl (
        .i_Clock       (i_Clock),
        .i_Reset       (i_Reset),
        .i_InstOp      (InstOP),
        .i_InstFn      (InstFN),
        .o_AluControl  (Ctrl_AluControl),
        .o_MemWrEnable (Ctrl_MemWrEnable),
        .o_RegWrEnable (Ctrl_RegWrEnable),
        .o_AluSrcB     (Ctrl_AluSrcB),
        .o_RegDst      (Ctrl_RegDst),
        .o_MemToReg    (Ctrl_MemToReg),
        .o_IsBranch    (Ctrl_IsBranch),
        .o_IsJump      (Ctrl_IsJump)); 

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
        .i_RdAddrA  (InstRS),
        .o_RdDataA  (RegBlock_RdDataA),
        .i_RdAddrB  (InstRT),
        .o_RdDataB  (RegBlock_RdDataB));


    // Selecciona les dades d'entrada B de la ALU
    //
    logic [DATA_DBUS_WIDTH-1:0] Sel1_Output;   
    Mux2To1 #(
        .WIDTH  (DATA_DBUS_WIDTH))
    Sel1 (
        .i_Select (Ctrl_AluSrcB),
        .i_Input0 (RegBlock_RdDataB),
        .i_Input1 (InstIMM16SX),
        .o_Output (Sel1_Output));


    // Selecciona el registre RT o RD de la instruccio
    //
    logic [INDEX_WIDTH-1:0] Sel2_Output;  
    Mux2To1 #(
        .WIDTH  (INDEX_WIDTH))
    Sel2 (
        .i_Select (Ctrl_RegDst),
        .i_Input0 (InstRT),
        .i_Input1 (InstRD),
        .o_Output (Sel2_Output));


    // Selecciona les dades per escriure en el registre
    //
    logic [DATA_DBUS_WIDTH-1:0] Sel3_Output;  
    Mux2To1 #(
        .WIDTH  (DATA_DBUS_WIDTH))
    Sel3 (
        .i_Select (Ctrl_MemToReg),
        .i_Input0 (Alu_Result),
        .i_Input1 (i_MemRdData),
        .o_Output (Sel3_Output));


    // ALU
    //
    logic [DATA_DBUS_WIDTH-1:0] Alu_Result; 
    Alu #(
        .WIDTH      (DATA_DBUS_WIDTH))
    Alu (
        .i_Op       (Ctrl_AluControl),
        .i_Carry    (0),
        .i_OperandA (RegBlock_RdDataA),
        .i_OperandB (Sel1_Output),
        .o_Result   (Alu_Result));


    // Evalua PCPlus4
    //
    HalfAdder #(
        .WIDTH (ADDR_IBUS_WIDTH))
    Adder1 (
        .i_OperandA (PC),
        .i_OperandB (4),
        .o_Result   (PCPlus4));


    // Evalua PCBranch
    //
    HalfAdder #(
        .WIDTH (ADDR_IBUS_WIDTH))
    Adder2 (
        .i_OperandA (PCPlus4),
        .i_OperandB ({InstIMM16SX[29:0], 2'b00}),
        .o_Result   (PCBranch));


    // Evalua PCJump
    //
    assign PCJump = {PC[31:28], InstIMM26, 2'b00};


    // Selecciona el nou valor del contador de programa
    //
    Mux4To1 #(
        .WIDTH (ADDR_IBUS_WIDTH))
    Sel4 (
        .i_Select ({Ctrl_IsJump, Ctrl_IsBranch}),
        .i_Input0 (PCPlus4),
        .i_Input1 (PCBranch),
        .i_Input2 (PCJump),
        .i_Input3 (PCPlus4),
        .o_Output (PCNext));


    // Registre del contador de programa
    //
    Register #(
        .WIDTH (ADDR_IBUS_WIDTH),
        .INIT  (0))
    PCReg (
        .i_Clock    (i_Clock),
        .i_Reset    (i_Reset),
        .i_WrEnable (1),
        .i_WrData   (PCNext),
        .o_RdData   (PC));


    // Interface amb la memoria RAM
    //
    always_comb begin
        o_MemAddr     = Alu_Result;
        o_MemWrEnable = Ctrl_MemWrEnable;
        o_MemWrData   = RegBlock_RdDataB;
    end


    // Interface amb la memoria de programa
    //
    assign o_PgmAddr  = PC;

endmodule


