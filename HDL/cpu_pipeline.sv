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
    logic [DATA_DBUS_WIDTH-1:0] ID_DataA;
    logic [DATA_DBUS_WIDTH-1:0] ID_DataB;
    logic [INDEX_WIDTH-1:0]     ID_InstRT;
    logic [INDEX_WIDTH-1:0]     ID_InstRD;
    logic [DATA_DBUS_WIDTH-1:0] ID_InstIMM;
    logic [ADDR_IBUS_WIDTH-1:0] ID_pc_plus4;
    logic                       ID_reg_we;
    logic                       ID_MemToReg;
    logic                       ID_MemWrite;
    logic                       ID_Branch;
    logic                       ID_Jump;
    AluOp                       ID_AluControl;
    logic                       ID_AluSrcB;
    logic                       ID_RegDst;
    
    // EX pipeline
    logic                       EX_zero;
    logic [DATA_DBUS_WIDTH-1:0] EX_AluOut;
    logic [DATA_DBUS_WIDTH-1:0] EX_WriteData;
    logic [4:0]                 EX_WriteReg;
    logic [ADDR_IBUS_WIDTH-1:0] EX_BranchAddr;
    logic                       EX_reg_we;
    logic                       EX_MemToReg;
    logic                       EX_MemWrite;
    logic                       EX_pc_wdata;                  
    logic                       EX_Jump;
    logic                       EX_Branch;
    
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
        .i_pc_we        (EX_Jump | (EX_zero & EX_Branch)),
        .i_pc_wdata     (EX_pc_wdata),
        
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
        .i_clk            (i_clk),
        .i_rst            (i_rst),

        // Entrades del pipeline
        .i_inst           (IF_inst),
        .i_pc_plus4       (IF_pc_plus4),
        .i_reg_waddr      (MEM_WriteReg),
        .i_reg_wdata      (WB_Result),
        .i_reg_we         (MEM_reg_we),

        // Sortides del pipeline        
        .o_pc_plus4       (ID_pc_plus4),
        .o_Branch         (ID_Branch),
        .o_Jump           (ID_Jump),
        .o_DataA          (ID_DataA),
        .o_DataB          (ID_DataB),
        .o_reg_we         (ID_reg_we),
        .o_RegDst         (ID_RegDst),
        .o_MemWriteEnable (ID_MemWrite),
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
        
        // Entrades del pipeline
        .i_pc_plus4       (ID_pc_plus4),
        .i_DataA          (ID_DataA),
        .i_DataB          (ID_DataB),
        .i_AluControl     (ID_AluControl),
        .i_AluSrcB        (ID_AluSrcB),
        .i_reg_we         (ID_reg_we),
        .i_MemWriteEnable (ID_MemWrite),
        .i_RegDst         (ID_RegDst),
        .i_MemToReg       (ID_MemToReg),
        .i_InstRT         (ID_InstRT),
        .i_InstRD         (ID_InstRD),
        .i_InstIMM        (ID_InstIMM),
        .i_Branch         (ID_Branch),
        .i_Jump           (ID_Jump),
        
        // Sortides del pipeline
        .o_AluOut         (EX_AluOut),
        .o_reg_we         (EX_reg_we),
        .o_WriteReg       (EX_WriteReg),
        .o_MemWriteEnable (EX_MemWrite),
        .o_WriteData      (EX_WriteData),
        .o_MemToReg       (EX_MemToReg),
        .o_pc_wdata       (EX_pc_wdata),
        .o_zero           (EX_zero),
        .o_Jump           (EX_Jump),
        .o_Branch         (EX_Branch));
        
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
        .i_MemWrite      (EX_MemWrite),
        
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


