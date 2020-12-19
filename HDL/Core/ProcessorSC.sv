`include "RV.svh"

module ProcessorSC
    import Types::*;
#(
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 32,
    parameter PC_WIDTH   = 32,
    parameter REG_WIDTH  = 5)
(
    input  logic         i_clock, // Clock
    input  logic         i_reset, // Reset

    DataMemoryBus.master dataBus,    // Bus de dades
    InstMemoryBus.master instBus);   // Bus d'instruccions
 
    
    // ------------------------------------------------------------------------
    // Program counter (PC)
    // ------------------------------------------------------------------------

    logic [PC_WIDTH-1:0] PC;       // Valor actual del PC
    logic [PC_WIDTH-1:0] PCNext;   // Valor per actualitzar PC
    logic [PC_WIDTH-1:0] PCPlus4;  // Valor incrementat (+4)
    
    
    // ------------------------------------------------------------------------
    // Depuracio
    // ------------------------------------------------------------------------
    
    logic [7:0] DbgCtrl_Tag;
    
    DebugController #(
        .DATA_WIDTH (DATA_WIDTH),
        .ADDR_WIDTH (ADDR_WIDTH),
        .REG_WIDTH  (REG_WIDTH),
        .PC_WIDTH   (PC_WIDTH))
    DbgCtrl (
        .i_Clock          (i_Clock),
        .i_Reset          (i_Reset),
        .i_ExTag          (DbgCtrl_Tag),
        .i_ExPC           (IBus.Addr),
        .i_ExInst         (IBus.Inst),
        .i_ExRegWrAddr    (Dec_InstRD),
        .i_ExRegWrData    (Sel3_Output),
        .i_ExRegWrEnable  (DpCtrl_RegWrEnable),
        .i_ExMemWrAddr    (DBus.Addr),
        .i_ExMemWrData    (DBus.WrData),
        .i_ExMemWrEnable  (DpCtrl_MemWrEnable),
        .o_Tag            (DbgCtrl_Tag));
   

    // ------------------------------------------------------------------------
    // Control del datapath. Genera les senyals de control
    // ------------------------------------------------------------------------
    
    AluOp       DpCtrl_AluControl;   // Operacio de la ALU
    logic       DpCtrl_RegWrEnable;  // Autoritza escriptura del regisres
    logic       DpCtrl_MemWrEnable;  // Autoritza escritura en memoria
    logic [1:0] DpCtrl_PCNextSel;    // Selector del seguent valor del PC
    logic [1:0] DpCtrl_RegWrDataSel; // Selector del les dades d'esacriptura en el registre
    logic [1:0] DpCtrl_OperandASel;  // Seleccio del operand A de la ALU
    logic [1:0] DpCtrl_OperandBSel;  // Seleccio del operand B de la ALU

    DatapathController
    DpCtrl (
        .i_Inst         (IBus.Inst),
        .i_IsEQ         (Comp_EQ),
        .i_IsLT         (Comp_LT),
        .o_AluControl   (DpCtrl_AluControl),
        .o_MemWrEnable  (DpCtrl_MemWrEnable),
        .o_RegWrEnable  (DpCtrl_RegWrEnable),
        .o_OperandASel  (DpCtrl_OperandASel),
        .o_OperandBSel  (DpCtrl_OperandBSel),
        .o_RegWrDataSel (DpCtrl_RegWrDataSel),
        .o_PCNextSel    (DpCtrl_PCNextSel));


    // ------------------------------------------------------------------------
    // Decodificador d'instruccions. Extreu els parametres de la instruccio
    // ------------------------------------------------------------------------
    
    logic [31:0]          Dec_InstIMM;
    logic [REG_WIDTH-1:0] Dec_InstRS1;
    logic [REG_WIDTH-1:0] Dec_InstRS2;
    logic [REG_WIDTH-1:0] Dec_InstRD;

    // verilator lint_off PINMISSING
    InstDecoder
    Dec (
        .i_Inst (IBus.Inst),
        .o_RS1  (Dec_InstRS1),
        .o_RS2  (Dec_InstRS2),
        .o_RD   (Dec_InstRD),
        .o_IMM  (Dec_InstIMM));
    // verilator lint_on PINMISSING
    

    // ------------------------------------------------------------------------
    // Compara els valors del registre per decidir els salta condicionals
    // ------------------------------------------------------------------------
    
    logic Comp_EQ; // Indica A == B
    logic Comp_LT; // Indica A <= B
    
    // verilator lint_off PINMISSING
    Comparer #(
        .WIDTH (DATA_WIDTH))
    Comp (
        .i_InputA   (RegBlock_RdDataA),
        .i_InputB   (RegBlock_RdDataB),
        .i_Unsigned (0),
        .o_EQ       (Comp_EQ),
        .o_LT       (Comp_LT));
    // verilator lint_on PINMISSING


    // ------------------------------------------------------------------------
    // Bloc de registres
    // ------------------------------------------------------------------------
    
    logic [DATA_WIDTH-1:0] RegBlock_RdDataA, // Dades de lectura A
                           RegBlock_RdDataB; // Dades de lectura B
                           
    RegisterFile #(
        .DATA_WIDTH  (DATA_WIDTH),
        .ADDR_WIDTH  (REG_WIDTH))
    Regs (
        .i_Clock    (i_Clock),
        .i_Reset    (i_Reset),
        .i_WrAddr   (Dec_InstRD),
        .i_WrData   (Sel3_Output),
        .i_WrEnable (DpCtrl_RegWrEnable),
        .i_RdAddrA  (Dec_InstRS1),
        .o_RdDataA  (RegBlock_RdDataA),
        .i_RdAddrB  (Dec_InstRS2),
        .o_RdDataB  (RegBlock_RdDataB));
        
        
    // ------------------------------------------------------------------------
    // Selecciona les dades d'entrada A de la alu
    // ------------------------------------------------------------------------
    
    logic [DATA_WIDTH-1:0] Sel5_Output;
    
    // verilator lint_off PINMISSING
    Mux4To1 #(
        .WIDTH (DATA_WIDTH))
    Sel5 (
        .i_Select (DpCtrl_OperandASel),
        .i_Input0 (RegBlock_RdDataA),
        .i_Input1 ({{DATA_WIDTH-PC_WIDTH{1'b0}}, PC}),
        .i_Input2 ('d0),
        .o_Output (Sel5_Output));
    // verilator lint_on PINMISSING


    // ------------------------------------------------------------------------
    // Selecciona les dades d'entrada B de la ALU
    // ------------------------------------------------------------------------
    
    logic [DATA_WIDTH-1:0] Sel1_Output;   
    
    // verilator lint_off PINMISSING
    Mux4To1 #(
        .WIDTH (DATA_WIDTH))
    Sel1 (
        .i_Select (DpCtrl_OperandBSel),
        .i_Input0 (RegBlock_RdDataB),
        .i_Input1 (Dec_InstIMM),
        .i_Input2 ('d4),
        .o_Output (Sel1_Output));
    // verilator lint_on PINMISSING


    // ------------------------------------------------------------------------
    // Selecciona les dades per escriure en el registre
    // ------------------------------------------------------------------------
    
    logic [DATA_WIDTH-1:0] Sel3_Output;  
    
    // verilator lint_off PINMISSING
    Mux4To1 #(
        .WIDTH  (DATA_WIDTH))
    Sel3 (
        .i_Select (DpCtrl_RegWrDataSel),
        .i_Input0 (Alu_Result),             // Escriu el resultat de la ALU
        .i_Input1 (DBus.RdData),            // Escriu el valor lleigit de la memoria
        .i_Input2 ({{DATA_WIDTH-PC_WIDTH{1'b0}}, PCPlus4}), // Escriu el valor de PC+4
        .o_Output (Sel3_Output));
    // verilator lint_on PINMISSING


    // ------------------------------------------------------------------------
    // ALU
    // ------------------------------------------------------------------------
    
    logic [DATA_WIDTH-1:0] Alu_Result; 
    
    IntegerALU #(
        .WIDTH (DATA_WIDTH))
    Alu (
        .i_Op       (DpCtrl_AluControl),
        .i_OperandA (Sel5_Output),
        .i_OperandB (Sel1_Output),
        .o_Result   (Alu_Result));


    // Evalua PC = PC + 4
    //
    HalfAdder #(
        .WIDTH (PC_WIDTH))
    Adder1 (
        .i_OperandA (PC),
        .i_OperandB (4),
        .o_Result   (PCPlus4));


    // Evalua PC = PC + offset
    //
    logic [ADDR_WIDTH-1:0] PCPlusOffset;
    
    HalfAdder #(
        .WIDTH (PC_WIDTH))
    Adder2 (
        .i_OperandA (PC),
        .i_OperandB (Dec_InstIMM[PC_WIDTH-1:0]),
        .o_Result   (PCPlusOffset));
        
        
    // Evalua PC = [rs1] + offset
    //
    logic [PC_WIDTH-1:0] PCPlusOffsetAndRS1;
    
    HalfAdder #(
        .WIDTH (PC_WIDTH))
    Adder3 (
        .i_OperandA (Dec_InstIMM[PC_WIDTH-1:0]),
        .i_OperandB (RegBlock_RdDataA[PC_WIDTH-1:0]),
        .o_Result   (PCPlusOffsetAndRS1));


    // Selecciona el nou valor del contador de programa
    //
    Mux4To1 #(
        .WIDTH (PC_WIDTH))
    Sel4 (
        .i_Select (DpCtrl_PCNextSel),
        .i_Input0 (PCPlus4),
        .i_Input1 (PCPlusOffset),
        .i_Input2 (PCPlusOffsetAndRS1),
        .i_Input3 (PCPlus4),
        .o_Output (PCNext));
        
    // Registre del contador de programa
    //
    Register #(
        .WIDTH (PC_WIDTH),
        .INIT  ({PC_WIDTH{1'b0}}))
    PCReg (
        .i_Clock    (i_Clock),
        .i_Reset    (i_Reset),
        .i_WrEnable (1),
        .i_WrData   (PCNext),
        .o_RdData   (PC));


    // Interface amb la memoria RAM
    //
    always_comb begin
        DBus.Addr     = Alu_Result[ADDR_WIDTH-1:0];
        DBus.WrEnable = DpCtrl_MemWrEnable;
        DBus.WrData   = RegBlock_RdDataB;
    end


    // Interface amb la memoria de programa
    //
    assign IBus.Addr = PC;

endmodule


