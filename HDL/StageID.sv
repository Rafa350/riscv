import types::AluOp;

module StageID
#(
    parameter DATA_DBUS_WIDTH = 32,    // Data bus data width
    parameter DATA_IBUS_WIDTH = 32,    // Instruction bus data width
    parameter ADDR_IBUS_WIDTH = 32,    // Instruction bus address width
    parameter REG_WIDTH       = 5)     // Register address bus width
(
    input  logic                       i_Clock,        // Clock
    input  logic                       i_Reset,        // Reset
    
    input  logic [DATA_IBUS_WIDTH-1:0] i_Inst,         // Instruccio
    input  logic [ADDR_IBUS_WIDTH-1:0] i_PC,           // Adressa de la instruccio       
    input  logic [REG_WIDTH-1:0]       i_RegWrAddr,    // Registre a escriure
    input  logic [DATA_DBUS_WIDTH-1:0] i_RegWrData,    // El resultat a escriure
    input  logic                       i_RegWrEnable,  // Autoritzacio d'escriptura del registre
    
    output logic [ADDR_IBUS_WIDTH-1:0] o_PC,           // PC de la seguent instruccio       
    output logic [DATA_DBUS_WIDTH-1:0] o_DataA,        // Bus de dades A
    output logic [DATA_DBUS_WIDTH-1:0] o_DataB,        // Bus de dades B
    output logic [DATA_DBUS_WIDTH-1:0] o_InstIMM,      // Parametre IMM de la instruccio
    output logic                       o_RegWrEnable,  // Habilita l'escriptura del registre
    output logic                       o_MemWrEnable,  // Habilita l'escritura en memoria
    output logic [1:0]                 o_DataToRegSel,
    output AluOp                       o_AluControl,   // Codi de control de la ALU
    output logic                       o_OperandASel,  // Seleccio del origin de dades de la entrada A de la ALU
    output logic                       o_OperandBSel,  // Seleccio del origin de dades de la entrada B de la ALU
    output logic [ADDR_IBUS_WIDTH-1:0] o_JumpAddr,     // Adressa de salt
    output logic                       o_JumpEnable);  // Habilita el salt
              

    // Control del datapath. Genera les senyals de control
    //
    AluOp       Ctrl_AluControl;   // Operacio de la ALU
    logic       Ctrl_RegWrEnable;  // Autoritza escriptura del regisres
    logic       Ctrl_MemWrEnable;  // Autoritza escritura en memoria
    logic [1:0] Ctrl_PCNextSel;    // Selector del seguent valor del PC
    logic [1:0] Ctrl_DataToRegSel; // Selector del les dades d'escriptura en el registre
    logic       Ctrl_OperandASel;  // Seleccio del operand A de la ALU
    logic       Ctrl_OperandBSel;  // Seleccio del operand B de la ALU

    Controller_RV32I
    Ctrl (
        .i_Inst         (i_Inst),
        .i_IsEQ         (Comp_EQ),
        .i_IsLT         (Comp_LT),
        .o_AluControl   (Ctrl_AluControl),
        .o_MemWrEnable  (Ctrl_MemWrEnable),
        .o_RegWrEnable  (Ctrl_RegWrEnable),
        .o_OperandBSel  (Ctrl_OperandBSel),
        .o_DataToRegSel (Ctrl_DataToRegSel),
        .o_PCNextSel    (Ctrl_PCNextSel));
    assign Ctrl_OperandASel = 0;
        

    // Decodificador d'instruccions. Separa les instruccions en els seus components
    //
    logic [31:0] Dec_InstIMM;
    logic [6:0]  Dec_InstOP;
    logic [4:0]  Dec_InstSH;
    logic [4:0]  Dec_InstRS1;
    logic [4:0]  Dec_InstRS2;
    logic [4:0]  Dec_InstRD;

    Decoder_RV32I Dec (
        .i_Inst (i_Inst),
        .o_OP   (Dec_InstOP),
        .o_RS1  (Dec_InstRS1),
        .o_RS2  (Dec_InstRS2),
        .o_RD   (Dec_InstRD),
        .o_IMM  (Dec_InstIMM),
        .o_SH   (Dec_InstSH));
    
    
    // Comparador per les instruccions de salt. 
    //
    logic Comp_EQ; // Indica A == B
    logic Comp_LT; // Indica A <= B
    
    // verilator lint_off PINMISSING
    Comparer Comp(
        .i_InputA   (Regs_DataA),
        .i_InputB   (Regs_DataB),
        .i_Unsigned (0),
        .o_EQ       (Comp_EQ),
        .o_LT       (Comp_LT));
    // verilator lint_on PINMISSING
           
           
    // Bloc de registres
    //
    logic [DATA_DBUS_WIDTH-1:0] Regs_DataA;
    logic [DATA_DBUS_WIDTH-1:0] Regs_DataB;

    RegisterFile #(
        .DATA_WIDTH (DATA_DBUS_WIDTH),
        .ADDR_WIDTH (5))
    Regs (
        .i_Clock    (i_Clock),
        .i_Reset    (i_Reset),        
        .i_WrEnable (Ctrl_RegWrEnable),
        .i_RdAddrA  (Dec_InstRS1),
        .i_RdAddrB  (Dec_InstRS2),
        .i_WrAddr   (i_RegWrAddr),
        .i_WrData   (i_RegWrData),
        .o_RdDataA  (Regs_DataA),
        .o_RdDataB  (Regs_DataB));
          
          
    // Registres del pipeline de sortida
    //
    always_ff @(posedge i_Clock) begin
        o_PC           <= i_PC;
        o_DataA        <= i_Reset ? 32'b0     : Regs_DataA;
        o_DataB        <= i_Reset ? 32'b0     : Regs_DataB;
        o_RegWrEnable  <= i_Reset ? 1'b0      : Ctrl_RegWrEnable;
        o_MemWrEnable  <= i_Reset ? 1'b0      : Ctrl_MemWrEnable;
        o_DataToRegSel <= i_Reset ? 2'b0      : Ctrl_DataToRegSel;
        o_InstIMM      <= i_Reset ? 32'b0     : Dec_InstIMM;
        o_AluControl   <= i_Reset ? AluOp'(0) : Ctrl_AluControl;
        o_OperandASel  <= i_Reset ? 1'b0      : Ctrl_OperandASel;
        o_OperandBSel  <= i_Reset ? 1'b0      : Ctrl_OperandBSel;
    end
    
endmodule

    