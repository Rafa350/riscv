module stageMEM #(
    parameter DATA_DBUS_WIDTH = 32,
    parameter ADDR_DBUS_WIDTH = 32)
(
    input  logic                       i_Clock,
    input  logic                       i_Reset,
    
    input  logic [DATA_DBUS_WIDTH-1:0] i_mem_rdata,
    output logic [DATA_DBUS_WIDTH-1:0] o_mem_wdata,
    output logic [ADDR_DBUS_WIDTH-1:0] o_mem_addr,
    output logic                       o_mem_we,
    
    input  logic [DATA_DBUS_WIDTH-1:0] i_AluResult,
    input  logic [DATA_DBUS_WIDTH-1:0] i_WriteData,
    input  logic [4:0]                 i_WriteReg,
    input  logic                       i_RegWrEnable,
    input  logic                       i_MemToReg,
    input  logic                       i_MemWrEnable,
    
    output logic [DATA_DBUS_WIDTH-1:0] o_AluOut,
    output logic [DATA_DBUS_WIDTH-1:0] o_ReadData,
    output logic [4:0]                 o_WriteReg,
    output logic                       o_RegWrEnable,
    output logic                       o_MemToReg);

    always_comb begin
        o_mem_we    = i_MemWrEnable;
        o_mem_addr  = i_AluResult;
        o_mem_wdata = i_WriteData;
    end
    
    always_ff @(posedge i_Clock) begin
        if (i_Reset) begin
            o_AluOut      <= 0;
            o_ReadData    <= 0;
            o_WriteReg    <= 0;
            o_RegWrEnable <= 0;
            o_MemToReg    <= 0;
        end
        else begin
            o_AluOut      <= i_AluResult;
            o_ReadData    <= i_mem_rdata;
            o_WriteReg    <= i_WriteReg;
            o_RegWrEnable <= i_RegWrEnable;
            o_MemToReg    <= i_MemToReg;
        end
    end

endmodule
