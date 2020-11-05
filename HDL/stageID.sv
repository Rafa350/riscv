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
    input  logic                       i_clk,              // Clock
    input  logic                       i_rst,              // Reset
    
    // Entrades del pipeline
    //
    input  logic [DATA_IBUS_WIDTH-1:0] i_Inst,             // Instructruccio
    input  logic [ADDR_IBUS_WIDTH-1:0] i_PCPlus4,          // PC de la seguent instruccio       
    input  logic [REG_WIDTH-1:0]       i_RegToWrite,       // Registre a escriure
    input  logic [DATA_DBUS_WIDTH-1:0] i_RegWriteData,     // Dades del registre a escriure
    input  logic                       i_RegWriteEnable,   // Autoritzacio d'escriptura del registre
    
    // Sortides del pipeline
    //
    output logic [DATA_DBUS_WIDTH-1:0] o_DataA,            // Bus de dades A
    output logic [DATA_DBUS_WIDTH-1:0] o_DataB,            // DBus de dades B
    output logic [REG_WIDTH-1:0]       o_InstRT,           // Parametre RT de la instruccio
    output logic [REG_WIDTH-1:0]       o_InstRD,           // Parametre RD de la instruccio
    output logic [DATA_DBUS_WIDTH-1:0] o_InstIMM,          // Parametre IMM de la instruccio
    output logic                       o_RegWriteEnable,   // Autoritza la escriptura del registre
    output logic                       o_MemWriteEnable,   // Autoritza la escritura en memoria
    output logic                       o_RegDst,           // Destination reg selection
    output logic                       o_MemToReg,
    output logic [2:0]                 o_AluControl,       // Codi de control de la ALU
    output logic                       o_AluSrcB,          // Seleccio del origin de dades de la entrada B de la ALU
    output logic                       o_BranchRequest,    // Sol·licitut de salt
    output logic [ADDR_IBUS_WIDTH-1:0] o_PCPlus4);         // PC de la seguent instruccio
    
    // Senyals internes
    //
    logic [DATA_DBUS_WIDTH-1:0] DataA;
    logic [DATA_DBUS_WIDTH-1:0] DataB;
    logic [2:0]                 AluControl;
    logic                       AluSrcB;
    logic                       RegDst;
    logic                       RegWriteEnable;
    logic                       MemWriteEnable;
    logic                       MemToReg;
    InstOp InstOP;
    InstFn InstFN;
    logic [REG_WIDTH-1:0] InstRS;
    logic [REG_WIDTH-1:0] InstRT;
    logic [REG_WIDTH-1:0] InstRD;
    logic [DATA_DBUS_WIDTH-1:0] InstIMM;
    logic BranchRequest;
       
       
    assign InstOP = InstOp'(i_Inst[31:26]);
    assign InstFN = InstFn'(i_Inst[5:0]);
    assign InstRS = i_Inst[25:21];
    assign InstRT = i_Inst[20:16];
    assign InstRD = i_Inst[15:11];
    assign InstIMM = {{16{i_Inst[15]}}, i_Inst[15:0]};
    
    controller controller(
        .i_clk           (i_clk),
        .i_rst           (i_rst),
        .i_inst_op       (InstOP),
        .i_inst_fn       (InstFN),
        .o_AluControl    (AluControl),
        .o_AluSrc        (AluSrcB),
        .o_MemWrite      (MemWriteEnable),
        .o_RegWrite      (RegWriteEnable),
        .o_RegDst        (RegDst),
        .o_MemToReg      (MemToReg),      
        .o_BranchRequest (BranchRequest));
           
           
    regfile #(
        .DATA_WIDTH (DATA_DBUS_WIDTH),
        .REG_WIDTH  (5))
    regs (
        .i_clk       (i_clk),
        .i_rst       (i_rst),        
        .i_we        (i_RegWriteEnable),
        .i_rd_reg_A  (InstRS),
        .i_rd_reg_B  (InstRT),
        .i_wr_reg    (i_RegToWrite),
        .i_wr_data   (i_RegWriteData),
        .o_rd_data_A (DataA),
        .o_rd_data_B (DataB));

    // Actualitza els registres del pipeline de sortida
    //
    always_ff @(posedge i_clk) begin
        o_DataA          <= DataA;
        o_DataB          <= DataB;
        o_RegWriteEnable <= RegWriteEnable;
        o_RegDst         <= RegDst;
        o_MemWriteEnable <= MemWriteEnable;
        o_MemToReg       <= MemToReg;
        o_InstRT         <= InstRT;
        o_InstRD         <= InstRD;
        o_InstIMM        <= InstIMM;
        o_AluControl     <= AluControl;
        o_AluSrcB        <= AluSrcB;
        o_BranchRequest  <= BranchRequest;
        o_PCPlus4        <= i_PCPlus4;
    end
    
endmodule