module StageMEM #(
    parameter DATA_DBUS_WIDTH = 32,
    parameter ADDR_DBUS_WIDTH = 32)
(
    input  logic                       i_Clock,
    input  logic                       i_Reset,
    
    input  logic [DATA_DBUS_WIDTH-1:0] i_MemRdData,
    output logic [DATA_DBUS_WIDTH-1:0] o_MemWrData,
    output logic [ADDR_DBUS_WIDTH-1:0] o_MemAddr,
    output logic                       o_MemWrEnable,
    
    input  logic [DATA_DBUS_WIDTH-1:0] i_AluResult,
    input  logic [DATA_DBUS_WIDTH-1:0] i_WriteData,
    input  logic [4:0]                 i_WriteReg,
    input  logic                       i_RegWrEnable,
    input  logic [1:0]                 i_DataToRegSel,
    input  logic                       i_MemWrEnable,
    
    output logic [DATA_DBUS_WIDTH-1:0] o_AluOut,
    output logic [DATA_DBUS_WIDTH-1:0] o_ReadData,
    output logic [4:0]                 o_WriteReg,
    output logic                       o_RegWrEnable,
    output logic [1:0]                 o_DataToRegSel);

    always_comb begin
        o_MemWrEnable = i_MemWrEnable;
        o_MemAddr     = i_AluResult;
        o_MemWrData   = i_WriteData;
    end
    
    always_ff @(posedge i_Clock) begin
        o_AluOut       <= i_Reset ? 0 : i_AluResult;
        o_ReadData     <= i_Reset ? 0 : i_MemRdData;
        o_WriteReg     <= i_Reset ? 0 : i_WriteReg;
        o_RegWrEnable  <= i_Reset ? 0 : i_RegWrEnable;
        o_DataToRegSel <= i_Reset ? 0 : i_DataToRegSel;
    end

endmodule
