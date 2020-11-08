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
    input  logic                       i_clk,           // Clock
    input  logic                       i_rst,           // Reset
    
    // Entrades del pipeline
    //
    input  logic [DATA_IBUS_WIDTH-1:0] i_inst,          // Instructruccio
    input  logic [ADDR_IBUS_WIDTH-1:0] i_pc_plus4,      // PC de la seguent instruccio       
    input  logic [REG_WIDTH-1:0]       i_reg_waddr,     // Registre a escriure
    input  logic [DATA_DBUS_WIDTH-1:0] i_reg_wdata,     // Dades del registre a escriure
    input  logic                       i_reg_we,        // Autoritzacio d'escriptura del registre
    
    // Sortides del pipeline
    //
    output logic [DATA_DBUS_WIDTH-1:0] o_dataA,          // Bus de dades A
    output logic [DATA_DBUS_WIDTH-1:0] o_dataB,          // Bus de dades B
    output logic [REG_WIDTH-1:0]       o_InstRT,         // Parametre RT de la instruccio
    output logic [REG_WIDTH-1:0]       o_InstRD,         // Parametre RD de la instruccio
    output logic [DATA_DBUS_WIDTH-1:0] o_InstIMM,        // Parametre IMM de la instruccio
    output logic                       o_reg_we,         // Habilita l'escriptura del registre
    output logic                       o_mem_we,         // Habilita l'escritura en memoria
    output logic                       o_RegDst,         // Destination reg selection
    output logic                       o_MemToReg,
    output AluOp                       o_AluControl,     // Codi de control de la ALU
    output logic                       o_AluSrcB,        // Seleccio del origin de dades de la entrada B de la ALU
    output logic                       o_is_branch,      // Salt condicional
    output logic                       o_is_jump,        // Sal incondicionat
    output logic [ADDR_IBUS_WIDTH-1:0] o_pc_plus4);      // PC de la seguent instruccio
    
    // Senyals internes
    //
    logic [DATA_DBUS_WIDTH-1:0] dataA;
    logic [DATA_DBUS_WIDTH-1:0] dataB;
    logic                       equals;
    AluOp                       AluControl;
    logic                       AluSrcB;
    logic                       RegDst;
    logic                       reg_we;
    logic                       mem_we;
    logic                       MemToReg;
    InstOp                      InstOP;
    InstFn                      InstFN;
    logic [REG_WIDTH-1:0]       InstRS;
    logic [REG_WIDTH-1:0]       InstRT;
    logic [REG_WIDTH-1:0]       InstRD;
    logic [DATA_DBUS_WIDTH-1:0] InstIMM;
    logic                       is_branch;
    logic                       is_jump;
       
       
    assign InstOP = InstOp'(i_inst[31:26]);
    assign InstFN = InstFn'(i_inst[5:0]);
    assign InstRS = i_inst[25:21];
    assign InstRT = i_inst[20:16];
    assign InstRD = i_inst[15:11];
    assign InstIMM = {{16{i_inst[15]}}, i_inst[15:0]};
    
    controller controller(
        .i_clk        (i_clk),
        .i_rst        (i_rst),
        .i_inst_op    (InstOP),
        .i_inst_fn    (InstFN),
        .o_AluControl (AluControl),
        .o_AluSrc     (AluSrcB),
        .o_mem_we     (mem_we),
        .o_reg_we     (reg_we),
        .o_RegDst     (RegDst),
        .o_MemToReg   (MemToReg),      
        .o_is_branch  (is_branch),
        .o_is_jump    (is_jump));
           
           
    regfile #(
        .DATA_WIDTH (DATA_DBUS_WIDTH),
        .ADDR_WIDTH  (5))
    regs (
        .i_clk    (i_clk),
        .i_rst    (i_rst),        
        .i_we     (i_reg_we),
        .i_raddrA (InstRS),
        .i_raddrB (InstRT),
        .i_waddr  (i_reg_waddr),
        .i_wdata  (i_reg_wdata),
        .o_rdataA (dataA),
        .o_rdataB (dataB));
    assign equals = dataA == dataB;

    // Actualitza els registres del pipeline de sortida
    //
    always_ff @(posedge i_clk) begin
        o_dataA      <= dataA;
        o_dataB      <= dataB;
        o_reg_we     <= reg_we;
        o_RegDst     <= RegDst;
        o_mem_we     <= mem_we;
        o_MemToReg   <= MemToReg;
        o_InstRT     <= InstRT;
        o_InstRD     <= InstRD;
        o_InstIMM    <= InstIMM;
        o_AluControl <= AluControl;
        o_AluSrcB    <= AluSrcB;
        o_is_branch  <= is_branch;
        o_is_jump    <= is_jump;
        o_pc_plus4   <= i_pc_plus4;
    end
    
endmodule