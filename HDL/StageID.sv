import types::AluOp;

module StageID
#(
    parameter DATA_DBUS_WIDTH = 32,    // Data bus data width
    parameter DATA_IBUS_WIDTH = 32,    // Instruction bus data width
    parameter ADDR_IBUS_WIDTH = 32,    // Instruction bus address width
    parameter REG_WIDTH       = 5)     // Register address bus width
(
    input  logic                       i_Clock,       // Clock
    input  logic                       i_Reset,       // Reset
    
    input  logic [DATA_IBUS_WIDTH-1:0] i_Inst,        // Instructruccio
    input  logic [ADDR_IBUS_WIDTH-1:0] i_PC,          // PC de la seguent instruccio       
    input  logic [REG_WIDTH-1:0]       i_RegWrAddr,   // Registre a escriure
    input  logic [DATA_DBUS_WIDTH-1:0] i_RegWrData,   // El resultat a escriure
    input  logic                       i_RegWrEnable, // Autoritzacio d'escriptura del registre
    
    output logic [DATA_DBUS_WIDTH-1:0] o_DataA,       // Bus de dades A
    output logic [DATA_DBUS_WIDTH-1:0] o_DataB,       // Bus de dades B
    output logic [REG_WIDTH-1:0]       o_InstRS,      // Parametre RS de la instruccio
    output logic [REG_WIDTH-1:0]       o_InstRT,      // Parametre RT de la instruccio
    output logic [REG_WIDTH-1:0]       o_InstRD,      // Parametre RD de la instruccio
    output logic [DATA_DBUS_WIDTH-1:0] o_InstIMM,     // Parametre IMM de la instruccio
    output logic                       o_RegWrEnable, // Habilita l'escriptura del registre
    output logic                       o_MemWrEnable, // Habilita l'escritura en memoria
    output logic                       o_RegDst,      // Destination reg selection
    output logic                       o_MemToReg,
    output AluOp                       o_AluControl,  // Codi de control de la ALU
    output logic                       o_AluSrcB,     // Seleccio del origin de dades de la entrada B de la ALU
    output logic [ADDR_IBUS_WIDTH-1:0] o_JumpAddr,    // Adressa de salt
    output logic                       o_JumpEnable); // Habilita el salt
              

    // Control del datapath. Genera les senyals de control
    //
    AluOp       Ctrl_AluControl;   // Operacio de la ALU
    logic       Ctrl_RegWrEnable;  // Autoritza escriptura del regisres
    logic       Ctrl_MemWrEnable;  // Autoritza escritura en memoria
    logic [1:0] Ctrl_PCNextSel;    // Selector del seguent valor del PC
    logic [1:0] Ctrl_DataToRegSel; // Selector del les dades d'esacriptura en el registre
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
    logic [4:0]  Dec_InstSH;
    logic [4:0]  Dec_InstRS1;
    logic [4:0]  Dec_InstRS2;
    logic [4:0]  Dec_InstRD;

    Decoder_RV32I Dec (
        .i_Inst (i_Inst),
        .o_RS1  (Dec_InstRS1),
        .o_RS2  (Dec_InstRS2),
        .o_RD   (Dec_InstRD),
        .o_IMM  (Dec_InstIMM),
        .o_SH   (Dec_InstSH));
    
    
    // Comparador per les instruccions de salt. 
    //
    logic Comp_EQ; // Indica A == B
    logic Comp_LT; // Indica A <= B
    
    Comparer Comp(
        .i_InputA (Resg_DataA),
        .i_InputB (Regs_DataB),
        .o_EQ     (Comp_EQ),
        .o_LT     (Comp_LT));
           
           
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
          
    
    // Evalua el salt (Instruccions Jump i Branch)
    //
    JumpAddressEvaluator 
    JumpAddressEvaluator (
        .i_PCPlus4    (i_PCPlus4),
        .i_InstIMM    (InstIMM),
        .i_InstJDST   (InstJDST),
        .i_IsJump     (Ctrl_IsJump),
        .i_IsBranch   (Ctrl_IsBranch),
        .i_CanBranch  (Comp_EQ),
        .o_JumpAddr   (o_JumpAddr),
        .o_JumpEnable (o_JumpEnable));
    
    // Registres del pipeline de sortida
    //
    always_ff @(posedge i_Clock) begin
        o_DataA       <= i_Reset ? 32'b0     : Regs_DataA;
        o_DataB       <= i_Reset ? 32'b0     : Regs_DataB;
        o_RegWrEnable <= i_Reset ? 1'b0      : Ctrl_RegWrEnable;
        o_RegDst      <= i_Reset ? 1'b0      : Ctrl_RegDst;
        o_MemWrEnable <= i_Reset ? 1'b0      : Ctrl_MemWrEnable;
        o_MemToReg    <= i_Reset ? 1'b0      : Ctrl_MemToReg;
        o_InstRS      <= i_Reset ? 5'b0      : InstRS;
        o_InstRT      <= i_Reset ? 5'b0      : InstRT;
        o_InstRD      <= i_Reset ? 5'b0      : InstRD;
        o_InstIMM     <= i_Reset ? 32'b0     : InstIMM;
        o_AluControl  <= i_Reset ? AluOp'(0) : Ctrl_AluControl;
        o_AluSrcB     <= i_Reset ? 1'b0      : Ctrl_AluSrcB;
    end
    
endmodule


// verilator lint_off DECLFILENAME
 module JumpAddressEvaluator
// verilator lint_on DECLFILENAME
#(
    parameter DATA_DBUS_WIDTH = 32,
    parameter ADDR_IBUS_WIDTH = 32)
(
    input  logic [ADDR_IBUS_WIDTH-1:0] i_PCPlus4,
// verilator lint_off UNUSED
    input  logic [DATA_DBUS_WIDTH-1:0] i_InstIMM,
// verilator lint_on UNUSED
    input  logic [25:0]                i_InstJDST,
    input  logic                       i_CanBranch,
    input  logic                       i_IsBranch,
    input  logic                       i_IsJump,
    
    output logic [ADDR_IBUS_WIDTH-1:0] o_JumpAddr,
    output logic                       o_JumpEnable);
    
    logic [ADDR_IBUS_WIDTH-1:0] adder_Result;
    HalfAdder #(
        .WIDTH (ADDR_IBUS_WIDTH))
    adder (
        .i_OperandA (i_PCPlus4),
        .i_OperandB ({i_InstIMM[29:0], 2'b00}),
        .o_Result   (adder_Result));   

    Mux4To1 #(
        .WIDTH (ADDR_IBUS_WIDTH))
    mux (
        .i_Select({i_IsJump, i_IsBranch}),
        .i_Input0(0),
        .i_Input1(adder_Result),
        .i_Input2({i_PCPlus4[31:28], i_InstJDST, 2'b00}),
        .i_Input3(0),
        .o_Output(o_JumpAddr));
    
    assign o_JumpEnable = i_IsJump | (i_IsBranch & i_CanBranch);
    
endmodule
    