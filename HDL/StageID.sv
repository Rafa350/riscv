import types::AluOp;

module StageID
#(
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 32,
    parameter PC_WIDTH   = 32,
    parameter REG_WIDTH  = 5) 
(
    // Senyals de control.
    input  logic                  i_Clock,        // Clock
    input  logic                  i_Reset,        // Reset

    // Senyals d'entrada de l'etapa anterior.
    input  logic [31:0]           i_Inst,         // Instruccio
    input  logic [PC_WIDTH-1:0]   i_PC,           // Adressa de la instruccio      
    
    // Senyals d'entrada de les etapes posteriors.
    input  logic [REG_WIDTH-1:0]  i_RegWrAddr,    // Registre a escriure
    input  logic [DATA_WIDTH-1:0] i_RegWrData,    // El resultat a escriure
    input  logic                  i_RegWrEnable,  // Autoritzacio d'escriptura del registre

    input  logic                  i_IDEX_RegWrEnable,
    input  logic [REG_WIDTH-1:0]  i_IDEX_RegWrAddr,
    input  logic [1:0]            i_IDEX_RegWrDataSel,
    input  logic [DATA_WIDTH-1:0] i_EX_RegWrData,
    input  logic                  i_EXMEM_RegWrEnable,
    input  logic [REG_WIDTH-1:0]  i_EXMEM_RegWrAddr,
    input  logic [DATA_WIDTH-1:0] i_MEM_RegWrData,
       
    output logic [6:0]            o_InstOP,       // Codi d'operacio de la instruccio
    output logic [REG_WIDTH-1:0]  o_InstRS1,      // Registre RS1 de la instruccio
    output logic [REG_WIDTH-1:0]  o_InstRS2,      // Registre RS2 de la instrruccio
    output logic [DATA_WIDTH-1:0] o_InstIMM,      // Valor inmediat de la instruccio
    output logic [DATA_WIDTH-1:0] o_DataA,        // Dades A (rs1)
    output logic [DATA_WIDTH-1:0] o_DataB,        // Dades B (rs2)
    output logic [REG_WIDTH-1:0]  o_RegWrAddr,    // Registre a escriure.
    output logic                  o_RegWrEnable,  // Habilita l'escriptura del registre
    output logic                  o_MemWrEnable,  // Habilita l'escritura en memoria
    output logic [1:0]            o_RegWrDataSel, // Seleccio de les dades per escriure en el registre (rd)
    output logic                  o_OperandASel,  // Seleccio del valor A de la ALU
    output logic                  o_OperandBSel,  // Seleccio del valor B de la ALU
    output AluOp                  o_AluControl,   // Codi de control de la ALU
    output logic [PC_WIDTH-1:0]   o_PCNext);      // Nou valor de PC
              

    // ------------------------------------------------------------------------
    // Control del datapath. 
    // Genera les senyals de control.
    // ------------------------------------------------------------------------
    
    AluOp       Ctrl_AluControl;   // Operacio de la ALU
    logic       Ctrl_RegWrEnable;  // Autoritza escriptura del regisres
    logic       Ctrl_MemWrEnable;  // Autoritza escritura en memoria
    logic [1:0] Ctrl_PCNextSel;    // Selector del seguent valor del PC
    logic [1:0] Ctrl_DataToRegSel; // Selector del les dades d'escriptura en el registre
    logic       Ctrl_OperandASel;  // Seleccio del operand A de la ALU
    logic       Ctrl_OperandBSel;  // Seleccio del operand B de la ALU

    Controller_RV32I
    Ctrl (
        .i_Inst         (i_Inst),             // La instruccio
        .i_IsEQ         (Comp_EQ),            // Indicador r1 == r2
        .i_IsLT         (Comp_LT),            // Indicador r1 < r2
        .o_MemWrEnable  (Ctrl_MemWrEnable),
        .o_RegWrEnable  (Ctrl_RegWrEnable),
        .o_RegWrDataSel (Ctrl_DataToRegSel),
        .o_AluControl   (Ctrl_AluControl),
        .o_OperandASel  (Ctrl_OperandASel),
        .o_OperandBSel  (Ctrl_OperandBSel),
        .o_PCNextSel    (Ctrl_PCNextSel));
        

    // ------------------------------------------------------------------------
    // Decodificador d'instruccions. 
    // Separa les instruccions en els seus components.
    // ------------------------------------------------------------------------
    
    logic [DATA_WIDTH-1:0] Dec_InstIMM;
    logic [6:0]            Dec_InstOP;
    logic [REG_WIDTH-1:0]  Dec_InstRS1;
    logic [REG_WIDTH-1:0]  Dec_InstRS2;
    logic [REG_WIDTH-1:0]  Dec_InstRD;

    Decoder_RV32I #(
        .REG_WIDTH (REG_WIDTH))
    Dec (
        .i_Inst (i_Inst),
        .o_OP   (Dec_InstOP),
        .o_RS1  (Dec_InstRS1),
        .o_RS2  (Dec_InstRS2),
        .o_RD   (Dec_InstRD),
        .o_IMM  (Dec_InstIMM));
    
    
    // ------------------------------------------------------------------------
    // Controlador de forwarding pel comparador
    // ------------------------------------------------------------------------
    
    logic [1:0]            IDFwdCtrl_DataASel, 
                           IDFwdCtrl_DataBSel;
    logic [DATA_WIDTH-1:0] DataASelector_Output,
                           DataBSelector_Output;
    
    IDForwardController #(
        .REG_WIDTH (REG_WIDTH))
    IDFwdCtrl(
        .i_InstRS1           (Dec_InstRS1),
        .i_InstRS2           (Dec_InstRS2),
        .i_IDEX_RegWrAddr    (i_IDEX_RegWrAddr),
        .i_IDEX_RegWrEnable  (i_IDEX_RegWrEnable),
        .i_IDEX_RegWrDataSel (i_IDEX_RegWrDataSel),
        .i_EXMEM_RegWrAddr   (i_EXMEM_RegWrAddr),
        .i_EXMEM_RegWrEnable (i_EXMEM_RegWrEnable),
        .i_MEMWB_RegWrAddr   (i_RegWrAddr),
        .i_MEMWB_RegWrEnable (i_RegWrEnable),
        .o_DataASel          (IDFwdCtrl_DataASel),
        .o_DataBSel          (IDFwdCtrl_DataBSel));
    
    Mux4To1 #(
        .WIDTH (DATA_WIDTH))
    DataASelector (
        .i_Select (IDFwdCtrl_DataASel),
        .i_Input0 (Regs_DataA),
        .i_Input1 (i_EX_RegWrData),
        .i_Input2 (i_MEM_RegWrData),
        .i_Input3 (i_RegWrData),
        .o_Output (DataASelector_Output));
        
    Mux4To1 #(
        .WIDTH (DATA_WIDTH))
    DataBSelector (
        .i_Select (IDFwdCtrl_DataBSel),
        .i_Input0 (Regs_DataB),
        .i_Input1 (i_EX_RegWrData),
        .i_Input2 (i_MEM_RegWrData),
        .i_Input3 (i_RegWrData),
        .o_Output (DataBSelector_Output));

    
    // ------------------------------------------------------------------------
    // Comparador per les instruccions de salt. 
    // Permet identificas les condicions de salt abans d'executar 
    // la instruccio.
    // ------------------------------------------------------------------------
    //
    logic Comp_EQ; // Indica A == B
    logic Comp_LT; // Indica A <= B
    
    // verilator lint_off PINMISSING
    Comparer #(
        .WIDTH (DATA_WIDTH))
    Comp(
        .i_InputA   (DataASelector_Output),
        .i_InputB   (DataBSelector_Output),
        .i_Unsigned (0),
        .o_EQ       (Comp_EQ),
        .o_LT       (Comp_LT));
    // verilator lint_on PINMISSING
           
        
    // ------------------------------------------------------------------------        
    // Bloc de registres.
    // ------------------------------------------------------------------------
    
    logic [DATA_WIDTH-1:0] Regs_DataA;
    logic [DATA_WIDTH-1:0] Regs_DataB;

    RegisterFile #(
        .DATA_WIDTH (DATA_WIDTH),
        .ADDR_WIDTH (REG_WIDTH))
    Regs (
        .i_Clock    (i_Clock),
        .i_Reset    (i_Reset),        

        .i_WrEnable (i_RegWrEnable),
        .i_WrAddr   (i_RegWrAddr),
        .i_WrData   (i_RegWrData),

        .i_RdAddrA  (Dec_InstRS1),
        .o_RdDataA  (Regs_DataA),
        
        .i_RdAddrB  (Dec_InstRS2),
        .o_RdDataB  (Regs_DataB));
               
        
    // ------------------------------------------------------------------------
    // Evaluacio de l'adressa de salt
    // ------------------------------------------------------------------------
    
    logic [PC_WIDTH-1:0] PCAlu_PC;

    PCAlu #(
        .DATA_WIDTH (DATA_WIDTH),
        .PC_WIDTH   (PC_WIDTH))
    PCAlu (
        .i_Op      (Ctrl_PCNextSel),
        .i_PC      (i_PC),
        .i_InstIMM (Dec_InstIMM),
        .i_RegData (Regs_DataA),
        .o_PC      (PCAlu_PC));
             
        
    always_comb begin        
        o_InstOP       = Dec_InstOP;
        o_InstRS1      = Dec_InstRS1;
        o_InstRS2      = Dec_InstRS2;
        o_InstIMM      = Dec_InstIMM;
        o_DataA        = Regs_DataA;
        o_DataB        = Regs_DataB;
        o_RegWrAddr    = Dec_InstRD;
        o_RegWrEnable  = Ctrl_RegWrEnable;
        o_RegWrDataSel = Ctrl_DataToRegSel;
        o_MemWrEnable  = Ctrl_MemWrEnable;
        o_OperandASel  = Ctrl_OperandASel;
        o_OperandBSel  = Ctrl_OperandBSel;
        o_AluControl   = Ctrl_AluControl;
        o_PCNext       = PCAlu_PC;
    end
    
    
endmodule






    