import types::*;


module stageEX 
#(
    parameter DATA_DBUS_WIDTH = 32,
    parameter ADDR_IBUS_WIDTH = 32)
(
    // Senyals de control
    //
    input  logic                       i_clk,
    input  logic                       i_rst,
    
    // Entrades del pipeline
    //
    input  logic [DATA_DBUS_WIDTH-1:0] i_DataA,
    input  logic [DATA_DBUS_WIDTH-1:0] i_DataB,
    input  logic                       i_RegWriteEnable,
    input  logic                       i_MemWriteEnable,
    input  logic                       i_RegDst,
    input  logic                       i_MemToReg,
    input  AluOp                       i_AluControl,
    input  logic                       i_AluSrcB,
    input  logic [ADDR_IBUS_WIDTH-1:0] i_PCPlus4,
    input  logic [4:0]                 i_InstRT,
    input  logic [4:0]                 i_InstRD,
    input  logic [DATA_DBUS_WIDTH-1:0] i_InstIMM,
    input  logic                       i_BranchRequest,
    
    // Sortides del pipeline
    //
    output logic [DATA_DBUS_WIDTH-1:0] o_WriteData,
    output logic [DATA_DBUS_WIDTH-1:0] o_AluOut,
    output logic                       o_Zero,
    output logic                       o_RegWriteEnable,
    output logic                       o_MemWriteEnable,
    output logic                       o_MemToReg,
    output logic [4:0]                 o_WriteReg,
    output logic [ADDR_IBUS_WIDTH-1:0] o_BranchAddr,
    output logic                       o_BranchRequest);

    // SZenyals internes
    //
    logic [DATA_DBUS_WIDTH-1:0] DataB;
    logic [DATA_DBUS_WIDTH-1:0] AluOut;
    logic                       Zero;
    logic                       Carry;
    logic [4:0]                 WriteReg;
    logic [ADDR_IBUS_WIDTH-1:0] BranchAddr;
    
    mux2 #(
        .WIDTH  (DATA_DBUS_WIDTH))
    mux_dataB (
        .i_sel (i_AluSrcB),
        .i_in0 (i_DataB),
        .i_in1 (i_InstIMM),
        .o_out (DataB));
    
    mux2 #(
        .WIDTH  (5))
    mux_reg_dst (
        .i_sel (i_RegDst),
        .i_in0 (i_InstRT),
        .i_in1 (i_InstRD),
        .o_out (WriteReg));
        
    alu #(
        .WIDTH (DATA_DBUS_WIDTH))
    alu (
        .i_op     (i_AluControl),
        .i_dataA  (i_DataA),
        .i_dataB  (DataB),
        .i_carry  (0),
        .o_result (AluOut),
        .o_zero   (Zero),
        .o_carry  (Carry));
    
    // Evalua la direccio de salt
    //
    always_comb
        BranchAddr = i_PCPlus4 + {i_InstIMM[31:2], 2'b00};

    // Actualitza els registres del pipeline
    //
    always_ff @(posedge i_clk) begin
        o_AluOut         <= AluOut;       
        o_Zero           <= Zero;
        o_WriteData      <= i_DataB;
        o_RegWriteEnable <= i_RegWriteEnable;
        o_MemWriteEnable <= i_MemWriteEnable;
        o_MemToReg       <= i_MemToReg;
        o_WriteReg       <= WriteReg;
        o_BranchRequest  <= i_BranchRequest;
        o_BranchAddr     <= BranchAddr;
    end    
    
endmodule
