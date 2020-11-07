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
    input  logic                       i_reg_we,
    input  logic                       i_MemWriteEnable,
    input  logic                       i_RegDst,
    input  logic                       i_MemToReg,
    input  AluOp                       i_AluControl,
    input  logic                       i_AluSrcB,
    input  logic [ADDR_IBUS_WIDTH-1:0] i_pc_plus4,
    input  logic [4:0]                 i_InstRT,
    input  logic [4:0]                 i_InstRD,
    input  logic [DATA_DBUS_WIDTH-1:0] i_InstIMM,
    input  logic                       i_Branch,
    input  logic                       i_Jump,
    
    // Sortides del pipeline
    //
    output logic [DATA_DBUS_WIDTH-1:0] o_WriteData,
    output logic [DATA_DBUS_WIDTH-1:0] o_AluOut,
    output logic                       o_zero,
    output logic                       o_reg_we,
    output logic                       o_MemWriteEnable,
    output logic                       o_MemToReg,
    output logic [4:0]                 o_WriteReg,
    output logic [ADDR_IBUS_WIDTH-1:0] o_pc_wdata,
    output logic                       o_Jump,
    output logic                       o_Branch);

    // Senyals internes
    //
    logic [DATA_DBUS_WIDTH-1:0] dataB;
    logic [DATA_DBUS_WIDTH-1:0] AluOut;
    logic                       zero;
    logic                       carry;
    logic [4:0]                 WriteReg;
    logic [ADDR_IBUS_WIDTH-1:0] pc_wdata;
    
    // Selecciona el valor de la entradas B de la alu
    //
    mux2 #(
        .WIDTH  (DATA_DBUS_WIDTH))
    mux_dataB (
        .i_sel (i_AluSrcB),
        .i_in0 (i_DataB),
        .i_in1 (i_InstIMM),
        .o_out (dataB));
    
    // Selecciona el registre d'escriptura del resultat
    //
    mux2 #(
        .WIDTH  (5))
    mux_reg_dst (
        .i_sel (i_RegDst),
        .i_in0 (i_InstRT),
        .i_in1 (i_InstRD),
        .o_out (WriteReg));
       
    // Realitzacio dels calcula
    //    
    alu #(
        .WIDTH (DATA_DBUS_WIDTH))
    alu (
        .i_op     (i_AluControl),
        .i_dataA  (i_DataA),
        .i_dataB  (dataB),
        .i_carry  (0),
        .o_result (AluOut),
        .o_zero   (zero),
        .o_carry  (carry));
    
    // Evalua la direccio de salt
    //
    always_comb
        pc_wdata = i_pc_plus4 + {i_InstIMM[31:2], 2'b00};

    // Actualitza els registres del pipeline
    //
    always_ff @(posedge i_clk) begin
        o_AluOut         <= AluOut;       
        o_zero           <= zero;
        o_WriteData      <= i_DataB;
        o_reg_we         <= i_reg_we;
        o_MemWriteEnable <= i_MemWriteEnable;
        o_MemToReg       <= i_MemToReg;
        o_WriteReg       <= WriteReg;
        o_Branch         <= i_Branch;
        o_Jump           <= i_Branch;
        o_pc_wdata       <= pc_wdata;
    end    
    
endmodule
