module stageMEM #(
    parameter DATA_DBUS_WIDTH = 32,
    parameter ADDR_DBUS_WIDTH = 32)
(
    // Senyals de control
    //
    input  logic                       i_clk,
    input  logic                       i_rst,
    
    // Interface amb la memoria RAM
    //
    input  logic [DATA_DBUS_WIDTH-1:0] i_mem_rdata,
    output logic [DATA_DBUS_WIDTH-1:0] o_mem_wdata,
    output logic [ADDR_DBUS_WIDTH-1:0] o_mem_addr,
    output logic                       o_mem_we,
    
    // Entrades del pipeline
    //
    input  logic [DATA_DBUS_WIDTH-1:0] i_AluOut,
    input  logic [DATA_DBUS_WIDTH-1:0] i_WriteData,
    input  logic [4:0]                 i_WriteReg,
    input  logic                       i_reg_we,
    input  logic                       i_MemToReg,
    input  logic                       i_MemWrite,
    input  logic                       i_BranchRequest,
    
    // Sortides del pipeline
    //
    output logic [DATA_DBUS_WIDTH-1:0] o_AluOut,
    output logic [DATA_DBUS_WIDTH-1:0] o_ReadData,
    output logic [4:0]                 o_WriteReg,
    output logic                       o_reg_we,
    output logic                       o_MemToReg);

    always_comb begin
        o_mem_we    = i_MemWrite;
        o_mem_addr  = i_AluOut;
        o_mem_wdata = i_WriteData;
    end
    
    always_ff @(posedge i_clk) begin
        o_AluOut   <= i_AluOut;
        o_ReadData <= i_mem_rdata;
        o_WriteReg <= i_WriteReg;
        o_reg_we   <= i_reg_we;
        o_MemToReg <= i_MemToReg;
    end

endmodule
