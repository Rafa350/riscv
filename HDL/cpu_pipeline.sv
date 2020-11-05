// verilator lint_off PINMISSING 
// verilator lint_off IMPORTSTAR 
// verilator lint_off UNUSED

import types::*;


module cpu_pipeline
#(
    parameter DATA_DBUS_WIDTH          = 32,
    parameter ADDR_DBUS_WIDTH          = 32,
    parameter DATA_IBUS_WIDTH          = 32,
    parameter ADDR_IBUS_WIDTH          = 32,
    parameter INDEX_WIDTH              = 5)
(
    input  logic                       i_clk,
    input  logic                       i_rst,
    
    input  logic [DATA_DBUS_WIDTH-1:0] i_mem_rd_data,
    output logic [DATA_DBUS_WIDTH-1:0] o_mem_wr_data,
    output logic [ADDR_DBUS_WIDTH-1:0] o_mem_addr,
    output logic                       o_mem_we,

    input  logic [DATA_IBUS_WIDTH-1:0] i_pgm_inst,
    output logic [ADDR_IBUS_WIDTH-1:0] o_pgm_addr);
          
    logic [ADDR_IBUS_WIDTH-1:0] IF_PCPlus4;
    logic [DATA_IBUS_WIDTH-1:0] IF_Inst;
    
    logic [ADDR_IBUS_WIDTH-1:0] ID_PCPlus4;
    logic                       ID_BranchRequest;
    logic [DATA_DBUS_WIDTH-1:0] ID_DataA;
    logic [DATA_DBUS_WIDTH-1:0] ID_DataB;
    logic [INDEX_WIDTH-1:0]     ID_InstRT;
    logic [INDEX_WIDTH-1:0]     ID_InstRD;
    logic [DATA_DBUS_WIDTH-1:0] ID_InstIMM;
    AluOp                       ID_AluControl;
    logic                       ID_AluSrcB;
    logic                       ID_RegWriteEnable;
    logic                       ID_MemWriteEnable;
    logic                       ID_MemToReg;
    logic                       ID_RegDst;
    
    logic [DATA_DBUS_WIDTH-1:0] EX_AluOut;
    logic [DATA_DBUS_WIDTH-1:0] EX_WriteData;
    logic                       EX_RegWriteEnable;
    logic                       EX_MemWriteEnable;
    logic                       EX_MemToReg;
    logic                       EX_BranchRequest;                  
    logic [ADDR_IBUS_WIDTH-1:0] EX_BranchAddr;
    
    logic                       MEM_RegWrite;
    logic                       MEM_MemToReg;
    
    logic BranchEnable = 0;
       
    // Pipeline stage IF
    //
    stageIF #(
        .DATA_IBUS_WIDTH (DATA_IBUS_WIDTH),
        .ADDR_IBUS_WIDTH (ADDR_IBUS_WIDTH))
    stageIF (
        .i_clk           (i_clk),
        .i_rst           (i_rst),

        .i_pgm_inst      (i_pgm_inst),
        .o_pgm_addr      (o_pgm_addr),

        .i_BranchEnable  (BranchEnable),
        .i_BranchAddr    (EX_BranchAddr),
        
        .o_PCPlus4       (IF_PCPlus4),
        .o_Inst          (IF_Inst));
        
    // Pipeline stage ID
    //
    stageID #(
        .DATA_DBUS_WIDTH (DATA_DBUS_WIDTH),
        .DATA_IBUS_WIDTH (DATA_IBUS_WIDTH),
        .ADDR_IBUS_WIDTH (ADDR_IBUS_WIDTH))
    stageID (
        .i_clk            (i_clk),
        .i_rst            (i_rst),

        .i_Inst           (IF_Inst),
        .i_PCPlus4        (IF_PCPlus4),

        .o_PCPlus4        (ID_PCPlus4),
        .o_BranchRequest  (ID_BranchRequest),
        .o_DataA          (ID_DataA),
        .o_DataB          (ID_DataB),
        .o_RegWriteEnable (ID_RegWriteEnable),
        .o_RegDst         (ID_RegDst),
        .o_MemWriteEnable (ID_MemWriteEnable),
        .o_MemToReg       (ID_MemToReg),
        .o_InstRT         (ID_InstRT),
        .o_InstRD         (ID_InstRD),
        .o_InstIMM        (ID_InstIMM),
        .o_AluControl     (ID_AluControl),
        .o_AluSrcB        (ID_AluSrcB));
        
    // Pipeline stage EX
    //
    stageEX #(
        .DATA_DBUS_WIDTH (DATA_DBUS_WIDTH))
    stageEX(
        .i_clk            (i_clk),
        .i_rst            (i_rst),
        
        .i_PCPlus4        (ID_PCPlus4),
        .i_DataA          (ID_DataA),
        .i_DataB          (ID_DataB),
        .i_AluControl     (ID_AluControl),
        .i_AluSrcB        (ID_AluSrcB),
        .i_RegWriteEnable (ID_RegWriteEnable),
        .i_MemWriteEnable (ID_MemWriteEnable),
        .i_RegDst         (ID_RegDst),
        .i_MemToReg       (ID_MemToReg),
        .i_InstRT         (ID_InstRT),
        .i_InstRD         (ID_InstRD),
        .i_InstIMM        (ID_InstIMM),
        .i_BranchRequest  (ID_BranchRequest),
        
        .o_AluOut         (EX_AluOut),
        .o_RegWriteEnable (EX_RegWriteEnable),
        .o_MemWriteEnable (EX_MemWriteEnable),
        .o_WriteData      (EX_WriteData),
        .o_MemToReg       (EX_MemToReg),
        .o_BranchAddr     (EX_BranchAddr),
        .o_BranchRequest  (EX_BranchRequest));
        
    // Pipeline stage MEM
    //
    stageMEM #(
        .DATA_DBUS_WIDTH (DATA_DBUS_WIDTH))
    stageMEM (
        .i_clk           (i_clk),
        .i_rst           (i_rst),
        
        .i_BranchRequest (EX_BranchRequest),
        
        .o_BranchEnable  (BranchEnable),
        .o_RegWrite      (MEM_RegWrite),
        .o_MemToReg      (MEM_MemToReg));

    // Memoria
    //
    assign o_mem_addr    = EX_AluOut;
    assign o_mem_we      = EX_MemWriteEnable;
    assign o_mem_wr_data = EX_WriteData;
          
endmodule


