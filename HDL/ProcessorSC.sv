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

    output logic [ADDR_DBUS_WIDTH-1:0] o_MemAddr,     // Adressa
    output logic                       o_MemWrEnable, // Habilita la escriptura
    output logic [DATA_DBUS_WIDTH-1:0] o_MemWrData,   // Dades per escriure
    input  logic [DATA_DBUS_WIDTH-1:0] i_MemRdData,   // Dades lleigides
    
    output logic [ADDR_IBUS_WIDTH-1:0] o_PgmAddr,     // Adressa de la instruccio
    input  logic [DATA_IBUS_WIDTH-1:0] i_PgmInst);    // Instruccio
    
    // Control de PC
    //
    logic [ADDR_IBUS_WIDTH-1:0] PC;       // Valor actual del PC
    logic [ADDR_IBUS_WIDTH-1:0] PCNext;   // Valor per actualitzar PC
    logic [ADDR_IBUS_WIDTH-1:0] PCPlus4;  // Valor incrementat (+4)
   

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
        .i_Inst         (i_PgmInst),
        .i_IsEQ         (Comp_EQ),
        .i_IsLT         (Comp_LT),
        .o_AluControl   (Ctrl_AluControl),
        .o_MemWrEnable  (Ctrl_MemWrEnable),
        .o_RegWrEnable  (Ctrl_RegWrEnable),
        .o_OperandBSel  (Ctrl_OperandBSel),
        .o_DataToRegSel (Ctrl_DataToRegSel),
        .o_PCNextSel    (Ctrl_PCNextSel));
    assign Ctrl_OperandASel = 0;


    // Decodificador d'instruccions. Extreu els parametres de la instruccio
    //
    logic [31:0] Dec_InstIMM;
    logic [4:0]  Dec_InstSH;
    logic [4:0]  Dec_InstRS1;
    logic [4:0]  Dec_InstRS2;
    logic [4:0]  Dec_InstRD;

    Decoder_RV32I
    Dec (
        .i_Inst (i_PgmInst),
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
        
    // Selecciona les dades d'entrada A de la alu
    //
    logic [DATA_DBUS_WIDTH-1:0] Sel5_Output;
    Mux2To1 #(
        .WIDTH (DATA_DBUS_WIDTH))
    Sel5 (
        .i_Select (Ctrl_OperandASel),
        .i_Input0 (RegBlock_RdDataA),
        .i_Input1 (PC),
        .o_Output (Sel5_Output));

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
        .i_Select (Ctrl_DataToRegSel),
        .i_Input0 (Alu_Result),          // Escriu el resultat de la ALU
        .i_Input1 (i_MemRdData),         // Escriu el valor lleigit de la memoria
        .i_Input2 (PCPlus4),             // Escriu el valor de PC+4
        .i_Input3 (PCPlus4),             // No s'utilitza
        .o_Output (Sel3_Output));


    // ALU
    //
    logic [DATA_DBUS_WIDTH-1:0] Alu_Result; 
    Alu #(
        .WIDTH      (DATA_DBUS_WIDTH))
    Alu (
        .i_Op       (Ctrl_AluControl),
        .i_OperandA (Sel5_Output),
        .i_OperandB (Sel1_Output),
        .o_Result   (Alu_Result));


    // Evalua PC = PC + 4
    //
    HalfAdder #(
        .WIDTH (ADDR_IBUS_WIDTH))
    Adder1 (
        .i_OperandA (PC),
        .i_OperandB (4),
        .o_Result   (PCPlus4));


    // Evalua PC = PC + offset
    //
    logic [ADDR_IBUS_WIDTH-1:0] PCPlusOffset;
    HalfAdder #(
        .WIDTH (ADDR_IBUS_WIDTH))
    Adder2 (
        .i_OperandA (PC),
        .i_OperandB (Dec_InstIMM),
        .o_Result   (PCPlusOffset));
        
        
    // Evalua PC = [rs1] + offset
    //
    logic [ADDR_IBUS_WIDTH-1:0] PCPlusOffsetAndRS1;
    HalfAdder #(
        .WIDTH (ADDR_IBUS_WIDTH))
    Adder3 (
        .i_OperandA (Dec_InstIMM),
        .i_OperandB (RegBlock_RdDataA),
        .o_Result   (PCPlusOffsetAndRS1));


    // Selecciona el nou valor del contador de programa
    //
    Mux4To1 #(
        .WIDTH (ADDR_IBUS_WIDTH))
    Sel4 (
        .i_Select (Ctrl_PCNextSel),
        .i_Input0 (PCPlus4),
        .i_Input1 (PCPlusOffset),
        .i_Input2 (PCPlusOffsetAndRS1),
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


