// verilator lint_off IMPORTSTAR 


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
    
    input  logic [DATA_DBUS_WIDTH-1:0] i_mem_rdata,
    output logic [DATA_DBUS_WIDTH-1:0] o_mem_wdata,
    output logic [ADDR_DBUS_WIDTH-1:0] o_mem_addr,
    output logic                       o_mem_we,

    input  logic [DATA_IBUS_WIDTH-1:0] i_pgm_inst,
    output logic [ADDR_IBUS_WIDTH-1:0] o_pgm_addr);
          
    // IF pipeline
    logic [DATA_IBUS_WIDTH-1:0] IF_inst;
    logic [ADDR_IBUS_WIDTH-1:0] IF_pc_plus4;
    
    // ID pipeline
    logic [DATA_DBUS_WIDTH-1:0] ID_dataA;
    logic [DATA_DBUS_WIDTH-1:0] ID_dataB;
    logic [INDEX_WIDTH-1:0]     ID_InstRT;
    logic [INDEX_WIDTH-1:0]     ID_InstRD;
    logic [DATA_DBUS_WIDTH-1:0] ID_InstIMM;
    logic [ADDR_IBUS_WIDTH-1:0] ID_pc_plus4;
    logic                       ID_reg_we;
    logic                       ID_MemToReg;
    logic                       ID_mem_we;
    logic                       ID_is_branch;
    logic                       ID_is_jump;
    AluOp                       ID_AluControl;
    logic                       ID_AluSrcB;
    logic                       ID_RegDst;
    
    // EX pipeline
    logic                       EX_is_zero;
    logic [DATA_DBUS_WIDTH-1:0] EX_AluOut;
    logic [DATA_DBUS_WIDTH-1:0] EX_WriteData;
    logic [4:0]                 EX_WriteReg;
    logic [ADDR_IBUS_WIDTH-1:0] EX_BranchAddr;
    logic                       EX_reg_we;
    logic                       EX_MemToReg;
    logic                       EX_mem_we;
    logic                       EX_pc_branch;                  
    logic                       EX_is_jump;
    logic                       EX_is_branch;
    
    // MEM pipeline
    logic [DATA_DBUS_WIDTH-1:0] MEM_AluOut;
    logic [DATA_DBUS_WIDTH-1:0] MEM_ReadData;
    logic [4:0]                 MEM_WriteReg;
    logic                       MEM_reg_we;
    logic                       MEM_MemToReg;
    
    // WB pipeline
    logic [DATA_DBUS_WIDTH-1:0] WB_Result;
       
    // Pipeline stage IF
    //
    stageIF #(
        .DATA_IBUS_WIDTH (DATA_IBUS_WIDTH),
        .ADDR_IBUS_WIDTH (ADDR_IBUS_WIDTH))
    stageIF (
        .i_clk          (i_clk),
        .i_rst          (i_rst),

        // Interface amb la memoria del programa
        .i_pgm_inst     (i_pgm_inst),
        .o_pgm_addr     (o_pgm_addr),

        // Entrades del pipeline
        .i_pc_src       (EX_is_jump | (EX_is_zero & EX_is_branch)),
        .i_pc_branch    (EX_pc_branch),
        
        // Sortides del pipeline
        .o_pc_plus4     (IF_pc_plus4),
        .o_inst         (IF_inst));
        
    // Pipeline stage ID
    //
    stageID #(
        .DATA_DBUS_WIDTH (DATA_DBUS_WIDTH),
        .DATA_IBUS_WIDTH (DATA_IBUS_WIDTH),
        .ADDR_IBUS_WIDTH (ADDR_IBUS_WIDTH))
    stageID (
        .i_clk        (i_clk),
        .i_rst        (i_rst),

        // Entrades del pipeline
        .i_inst       (IF_inst),
        .i_pc_plus4   (IF_pc_plus4),
        .i_reg_waddr  (MEM_WriteReg),
        .i_reg_wdata  (WB_Result),
        .i_reg_we     (MEM_reg_we),

        // Sortides del pipeline        
        .o_pc_plus4   (ID_pc_plus4),
        .o_is_branch  (ID_is_branch),
        .o_is_jump    (ID_is_jump),
        .o_dataA      (ID_dataA),
        .o_dataB      (ID_dataB),
        .o_reg_we     (ID_reg_we),
        .o_RegDst     (ID_RegDst),
        .o_mem_we     (ID_mem_we),
        .o_MemToReg   (ID_MemToReg),
        .o_InstRT     (ID_InstRT),
        .o_InstRD     (ID_InstRD),
        .o_InstIMM    (ID_InstIMM),
        .o_AluControl (ID_AluControl),
        .o_AluSrcB    (ID_AluSrcB));
        
    // Pipeline stage EX
    //
    stageEX #(
        .DATA_DBUS_WIDTH (DATA_DBUS_WIDTH))
    stageEX(
        .i_clk        (i_clk),
        .i_rst        (i_rst),
        
        // Entrades del pipeline
        .i_pc_plus4   (ID_pc_plus4),
        .i_dataA      (ID_dataA),
        .i_dataB      (ID_dataB),
        .i_AluControl (ID_AluControl),
        .i_AluSrcB    (ID_AluSrcB),
        .i_reg_we     (ID_reg_we),
        .i_mem_we     (ID_mem_we),
        .i_RegDst     (ID_RegDst),
        .i_MemToReg   (ID_MemToReg),
        .i_InstRT     (ID_InstRT),
        .i_InstRD     (ID_InstRD),
        .i_InstIMM    (ID_InstIMM),
        .i_is_branch  (ID_is_branch),
        .i_is_jump    (ID_is_jump),
        
        // Sortides del pipeline
        .o_AluOut     (EX_AluOut),
        .o_reg_we     (EX_reg_we),
        .o_WriteReg   (EX_WriteReg),
        .o_mem_we     (EX_mem_we),
        .o_WriteData  (EX_WriteData),
        .o_MemToReg   (EX_MemToReg),
        .o_pc_branch  (EX_pc_branch),
        .o_is_zero    (EX_is_zero),
        .o_is_jump    (EX_is_jump),
        .o_is_branch  (EX_is_branch));
        
    // Pipeline stage MEM
    //
    stageMEM #(
        .DATA_DBUS_WIDTH (DATA_DBUS_WIDTH))
    stageMEM (
        .i_clk           (i_clk),
        .i_rst           (i_rst),
        
        // Interface amb la memoria RAM
        .o_mem_addr      (o_mem_addr),
        .i_mem_rdata     (i_mem_rdata),
        .o_mem_wdata     (o_mem_wdata),
        .o_mem_we        (o_mem_we),
        
        // Entrades del pipeline
        .i_AluOut        (EX_AluOut),
        .i_WriteData     (EX_WriteData),
        .i_WriteReg      (EX_WriteReg),
        .i_reg_we        (EX_reg_we),
        .i_MemToReg      (EX_MemToReg),
        .i_mem_we        (EX_mem_we),
        
        // Sortides del pipeline
        .o_AluOut        (MEM_AluOut),
        .o_ReadData      (MEM_ReadData),
        .o_WriteReg      (MEM_WriteReg),
        .o_reg_we        (MEM_reg_we),
        .o_MemToReg      (MEM_MemToReg));
        
    // Pipeline stage WB
    //
    stageWB
    stageWB (
        .i_clk (i_clk),
        .i_rst (i_rst),
        
        // Entrades del pipeline
        .i_AluOut        (MEM_AluOut),
        .i_ReadData      (MEM_ReadData),
        
        // Sortides del pipeline
        .o_Result        (WB_Result));
          
endmodule


