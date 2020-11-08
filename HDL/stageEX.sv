import types::*;


module stageEX 
#(
    parameter DATA_DBUS_WIDTH = 32,
    parameter ADDR_IBUS_WIDTH = 32)
(
    // Senyals de control
    //
    input  logic                       i_Clock,
    input  logic                       i_Reset,
    
    // Entrades del pipeline
    //
    input  logic [DATA_DBUS_WIDTH-1:0] i_dataA,
    input  logic [DATA_DBUS_WIDTH-1:0] i_dataB,
    input  logic                       i_reg_we,
    input  logic                       i_mem_we,
    input  logic                       i_RegDst,
    input  logic                       i_MemToReg,
    input  AluOp                       i_AluControl,
    input  logic                       i_AluSrcB,
    input  logic [ADDR_IBUS_WIDTH-1:0] i_pc_plus4,
    input  logic [4:0]                 i_InstRT,
    input  logic [4:0]                 i_InstRD,
    input  logic [DATA_DBUS_WIDTH-1:0] i_InstIMM,
    input  logic                       i_is_branch,
    input  logic                       i_is_jump,
    
    // Sortides del pipeline
    //
    output logic [DATA_DBUS_WIDTH-1:0] o_WriteData,
    output logic [DATA_DBUS_WIDTH-1:0] o_AluOut,
    output logic                       o_is_zero,
    output logic                       o_reg_we,
    output logic                       o_MemWrEnable,
    output logic                       o_MemToReg,
    output logic [4:0]                 o_WriteReg,
    output logic [ADDR_IBUS_WIDTH-1:0] o_pc_branch,
    output logic                       o_is_jump,
    output logic                       o_is_branch);

    // Senyals internes
    //
    logic [DATA_DBUS_WIDTH-1:0] dataB;
    logic [DATA_DBUS_WIDTH-1:0] AluOut;
    logic                       zero;
    logic                       carry;
    logic [4:0]                 WriteReg;
    logic [ADDR_IBUS_WIDTH-1:0] pc_branch;
    
    // Selecciona el valor de la entradas B de la alu
    //
    Mux2To1 #(
        .WIDTH  (DATA_DBUS_WIDTH))
    mux_dataB (
        .i_Select (i_AluSrcB),
        .i_Input0 (i_dataB),
        .i_Input1 (i_InstIMM),
        .o_Output (dataB));
    
    // Selecciona el registre d'escriptura del resultat
    //
    Mux2To1 #(
        .WIDTH (5))
    mux_reg_dst (
        .i_Select (i_RegDst),
        .i_Input0 (i_InstRT),
        .i_Input1 (i_InstRD),
        .o_Output (WriteReg));
       
    // Realitzacio dels calcula
    //    
    alu #(
        .WIDTH (DATA_DBUS_WIDTH))
    alu (
        .i_op     (i_AluControl),
        .i_dataA  (i_dataA),
        .i_dataB  (dataB),
        .i_carry  (0),
        .o_result (AluOut),
        .o_zero   (zero),
        .o_carry  (carry));
    
    // Evalua la direccio de salt
    //
    always_comb
        pc_branch = i_pc_plus4 + {i_InstIMM[31:2], 2'b00};

    // Actualitza els registres del pipeline
    //
    always_ff @(posedge i_Clock) begin
        o_AluOut     <= AluOut;       
        o_is_zero    <= zero;
        o_WriteData  <= i_dataB;
        o_reg_we     <= i_reg_we;
        o_MemWrEnable     <= i_mem_we;
        o_MemToReg   <= i_MemToReg;
        o_WriteReg   <= WriteReg;
        o_is_branch  <= i_is_branch;
        o_is_jump    <= i_is_jump;
        o_pc_branch  <= pc_branch;
    end    
    
endmodule
