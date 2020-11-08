import types::*;


module stageID
#(
    parameter DATA_DBUS_WIDTH = 32,    // Data bus data width
    parameter DATA_IBUS_WIDTH = 32,    // Instruction bus data width
    parameter ADDR_IBUS_WIDTH = 32,    // Instruction bus address width
    parameter REG_WIDTH       = 5)     // Register address bus width
(
    // Senyals de control
    //
    input  logic                       i_Clock,       // Clock
    input  logic                       i_Reset,       // Reset
    
    // Entrades del pipeline
    //
    input  logic [DATA_IBUS_WIDTH-1:0] i_Inst,        // Instructruccio
    input  logic [ADDR_IBUS_WIDTH-1:0] i_PCPlus4,     // PC de la seguent instruccio       
    input  logic [REG_WIDTH-1:0]       i_RegWrAddr,   // Registre a escriure
    input  logic [DATA_DBUS_WIDTH-1:0] i_RegWrData,   // El resultat a escriure
    input  logic                       i_RegWrEnable, // Autoritzacio d'escriptura del registre
    
    // Sortides del pipeline
    //
    output logic [DATA_DBUS_WIDTH-1:0] o_DataA,       // Bus de dades A
    output logic [DATA_DBUS_WIDTH-1:0] o_DataB,       // Bus de dades B
    output logic [REG_WIDTH-1:0]       o_InstRT,      // Parametre RT de la instruccio
    output logic [REG_WIDTH-1:0]       o_InstRD,      // Parametre RD de la instruccio
    output logic [DATA_DBUS_WIDTH-1:0] o_InstIMM,     // Parametre IMM de la instruccio
    output logic                       o_RegWrEnable, // Habilita l'escriptura del registre
    output logic                       o_MemWrEnable, // Habilita l'escritura en memoria
    output logic                       o_RegDst,      // Destination reg selection
    output logic                       o_MemToReg,
    output AluOp                       o_AluControl,  // Codi de control de la ALU
    output logic                       o_AluSrcB,     // Seleccio del origin de dades de la entrada B de la ALU
    output logic                       o_IsBranch,    // Salt condicional
    output logic                       o_IsJump,      // Sal incondicionat
    output logic [ADDR_IBUS_WIDTH-1:0] o_PCPlus4);    // PC de la seguent instruccio
    
    // Senyals internes
    //
    AluOp                       AluControl;
    logic                       AluSrcB;
    logic                       RegDst;
    logic                       MemToReg;


    // Separacio de la instruccio en blocs
    //
    InstOp                      InstOP;
    InstFn                      InstFN;
    logic [REG_WIDTH-1:0]       InstRS;
    logic [REG_WIDTH-1:0]       InstRT;
    logic [REG_WIDTH-1:0]       InstRD;
    logic [DATA_DBUS_WIDTH-1:0] InstIMM;
       
    always_comb begin
        InstOP  = InstOp'(i_Inst[31:26]);
        InstFN  = InstFn'(i_Inst[5:0]);
        InstRS  = i_Inst[25:21];
        InstRT  = i_Inst[20:16];
        InstRD  = i_Inst[15:11];
        InstIMM = {{16{i_Inst[15]}}, i_Inst[15:0]};
    end
    
    // Control del datapath
    //
    logic Ctrl_IsBranch;
    logic Ctrl_IsJump;      
    logic Ctrl_RegWrEnable;
    logic Ctrl_MemWrEnable;
    
    controller Ctrl(
        .i_Clock      (i_Clock),
        .i_Reset      (i_Reset),
        .i_inst_op    (InstOP),
        .i_inst_fn    (InstFN),
        .o_AluControl (AluControl),
        .o_AluSrc     (AluSrcB),
        .o_mem_we     (Ctrl_MemWrEnable),
        .o_reg_we     (Ctrl_RegWrEnable),
        .o_RegDst     (RegDst),
        .o_MemToReg   (MemToReg),      
        .o_is_branch  (Ctrl_IsBranch),
        .o_is_jump    (Ctrl_IsJump));
           
           
    // Bloc de registres
    //
    logic [DATA_DBUS_WIDTH-1:0] RegBlock_DataA;
    logic [DATA_DBUS_WIDTH-1:0] RegBlock_DataB;

    RegBlock #(
        .DATA_WIDTH (DATA_DBUS_WIDTH),
        .ADDR_WIDTH  (5))
    RegBlock (
        .i_Clock    (i_Clock),
        .i_Reset    (i_Reset),        
        .i_WrEnable (i_RegWrEnable),
        .i_RdAddrA  (InstRS),
        .i_RdAddrB  (InstRT),
        .i_WrAddr   (i_RegWrAddr),
        .i_WrData   (i_RegWrData),
        .o_RdDataA  (RegBlock_DataA),
        .o_RdDataB  (RegBlock_DataB));
        
        
    // Obte el indicador de Zero pels salts condicionals
    //
    logic Ctrl_EQ;
    Comparer #(
        .WIDTH (DATA_DBUS_WIDTH))
    Comp (
        .i_InputA (RegBlock_DataA),
        .i_InputB (RegBlock_DataB),
        .o_EQ     (Ctrl_EQ));


    // Registres del pipeline de sortida
    //
    always_ff @(posedge i_Clock) begin
        o_DataA       <= RegBlock_DataA;
        o_DataB       <= RegBlock_DataB;
        o_RegWrEnable <= Ctrl_RegWrEnable;
        o_RegDst      <= RegDst;
        o_MemWrEnable <= Ctrl_MemWrEnable;
        o_MemToReg    <= MemToReg;
        o_InstRT      <= InstRT;
        o_InstRD      <= InstRD;
        o_InstIMM     <= InstIMM;
        o_AluControl  <= AluControl;
        o_AluSrcB     <= AluSrcB;
        o_IsBranch    <= Ctrl_IsBranch;
        o_IsJump      <= Ctrl_IsJump;
        o_PCPlus4     <= i_PCPlus4;
    end
    
endmodule