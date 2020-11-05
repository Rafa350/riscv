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
    input  logic [DATA_DBUS_WIDTH-1:0] i_mem_rd_data,
    output logic [DATA_DBUS_WIDTH-1:0] o_mem_wr_data,
    output logic [ADDR_DBUS_WIDTH-1:0] o_mem_addr,
    output logic                       o_mem_we,
    
    // Entrades del pipeline
    //
    input  logic [ADDR_DBUS_WIDTH-1:0] i_WriteAddr,
    input  logic [DATA_DBUS_WIDTH-1:0] i_WriteData,
    input  logic                       i_WriteReg,
    input  logic                       i_MemWrite,
    input  logic                       i_BranchRequest,
    input  logic                       i_Zero,
    
    // Sortides del pipeline
    //
    output logic                       o_BranchEnable,
    output logic                       o_WriteReg,
    output logic                       o_RegWrite,
    output logic                       o_MemToReg
);


    assign o_BranchEnable = i_BranchRequest & i_Zero;
    assign o_mem_we = i_MemWrite;
    assign o_mem_addr = i_WriteAddr;
    assign o_mem_wr_data = i_WriteData;

endmodule
