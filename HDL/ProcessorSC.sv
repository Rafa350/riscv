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

    RdWrBusInterface.Master            io_MemBus,                      
    RdBusInterface.Master              io_PgmBus);

    // Control de PC
    //
    logic [ADDR_IBUS_WIDTH-1:0] PC;       // Valor actual del PC
    logic [ADDR_IBUS_WIDTH-1:0] PCNext;   // Valor per actualitzar PC
    logic [ADDR_IBUS_WIDTH-1:0] PCPlus4;  // Valor incrementat (+4)
    logic [ADDR_IBUS_WIDTH-1:0] PCBranch; // Valor per bifurcacio
    logic [ADDR_IBUS_WIDTH-1:0] PCJump;   // Valor per salt
   

    // Control del datapath. Genera les senyals de control
    //
    AluOp Ctrl_AluControl;  // Operacio de la ALU
    logic Ctrl_RegWrEnable; // Autoritza escriptura del regisres
    logic Ctrl_MemWrEnable; // Autoritza escritura en memoria
    logic Ctrl_IsJump;      // Indica salt
    logic Ctrl_IsBranch;    // Indica bifurcacio
    logic Ctrl_MemToReg;    // Selector del les dades d'esacriptura en el registre
    logic Ctrl_OperandBSel; // Seleccio del operand B de la ALU

    Controller_RV32I
    Ctrl (
        .i_Inst        (io_PgmBus.RdData),
        .o_AluControl  (Ctrl_AluControl),
        .o_MemWrEnable (Ctrl_MemWrEnable),
        .o_RegWrEnable (Ctrl_RegWrEnable),
        .o_AluSrcB     (Ctrl_OperandBSel),
        .o_MemToReg    (Ctrl_MemToReg),
        .o_IsBranch    (Ctrl_IsBranch),
        .o_IsJump      (Ctrl_IsJump));    


    // Decodificador d'instruccions. Extreu els parametres de la instruccio
    //
    logic [31:0] Dec_InstIMM;
    logic [4:0]  Dec_InstSH;
    logic [4:0]  Dec_InstRS1;
    logic [4:0]  Dec_InstRS2;
    logic [4:0]  Dec_InstRD;

    Decoder_RV32I
    Dec (
        .i_Inst (io_PgmBus.RdData),
        .o_RS1  (Dec_InstRS1),
        .o_RS2  (Dec_InstRS2),
        .o_RD   (Dec_InstRD),
        .o_IMM  (Dec_InstIMM),
        .o_SH   (Dec_InstSH));
    

    // Compara els valors del registre per decidir els salta condicionals
    //
    logic Comp_EQ; // Indica A == B
    logic Comp_LT; // Indica A <= B
    Comparer #(
        .WIDTH (DATA_DBUS_WIDTH))
    Comp (
        .i_InputA   (RegBlock_RdDataA),
        .i_InputB   (RegBlock_RdDataB),
        .i_Unsigned (0),
        .o_EQ       (Comp_EQ),
        .o_LT       (Comp_LT));


    // Bloc de registres
    //
    logic [DATA_DBUS_WIDTH-1:0] RegBlock_RdDataA, // Dades de lectura A
                                RegBlock_RdDataB; // Dades de lectura B
    RegisterFile #(
        .DATA_WIDTH  (DATA_DBUS_WIDTH),
        .ADDR_WIDTH  (INDEX_WIDTH))
    Regs (
        .i_Clock    (i_Clock),
        .i_Reset    (i_Reset),
        .i_WrAddr   (Dec_InstRD),
        .i_WrData   (Sel3_Output),
        .i_WrEnable (Ctrl_RegWrEnable),
        .i_RdAddrA  (Dec_InstRS1),
        .o_RdDataA  (RegBlock_RdDataA),
        .i_RdAddrB  (Dec_InstRS2),
        .o_RdDataB  (RegBlock_RdDataB));


    // Selecciona les dades d'entrada B de la ALU
    //
    logic [DATA_DBUS_WIDTH-1:0] Sel1_Output;   
    Mux2To1 #(
        .WIDTH  (DATA_DBUS_WIDTH))
    Sel1 (
        .i_Select (Ctrl_OperandBSel),
        .i_Input0 (RegBlock_RdDataB),
        .i_Input1 (Dec_InstIMM),
        .o_Output (Sel1_Output));


    // Selecciona les dades per escriure en el registre
    //
    logic [DATA_DBUS_WIDTH-1:0] Sel3_Output;  
    Mux4To1 #(
        .WIDTH  (DATA_DBUS_WIDTH))
    Sel3 (
        .i_Select ({1'b0, Ctrl_MemToReg}),
        .i_Input0 (Alu_Result),
        .i_Input1 (io_MemBus.RdData),
        .i_Input2 (PCPlus4),
        .i_Input3 (PCPlus4),
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
        .i_OperandA (PC),
        .i_OperandB (Dec_InstIMM),
        .o_Result   (PCBranch));


    // Selecciona el nou valor del contador de programa
    //
    Mux2To1 #(
        .WIDTH (ADDR_IBUS_WIDTH))
    Sel4 (
        .i_Select (Ctrl_IsJump | (Ctrl_IsBranch & Comp_EQ)),
        .i_Input0 (PCPlus4),
        .i_Input1 (PCBranch),
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
        io_MemBus.Addr     = Alu_Result;
        io_MemBus.WrEnable = Ctrl_MemWrEnable;
        io_MemBus.WrData   = RegBlock_RdDataB;
    end


    // Interface amb la memoria de programa
    //
    assign io_PgmBus.Addr  = PC;

endmodule


