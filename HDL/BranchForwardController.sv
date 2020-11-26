module BranchForwardController
#(
    parameter REG_WIDTH = 5)
(
    input  logic [REG_WIDTH-1:0] i_InstRS1,
    input  logic [REG_WIDTH-1:0] i_InstRS2,
    input  logic [REG_WIDTH-1:0] i_IDEX_RegWrAddr,
    input  logic                 i_IDEX_RegWrEnable,
    input  logic [REG_WIDTH-1:0] i_EXMEM_RegWrAddr,
    input  logic                 i_EXMEM_RegWrEnable,
    input  logic [REG_WIDTH-1:0] i_MEMWB_RegWrAddr,
    input  logic                 i_MEMWB_RegWrEnable,
    

    output logic [1:0]           o_DataASel,     // Seleccio del valor de RS1
    output logic [1:0]           o_DataBSel);    // Seleccio del valor de RS2


endmodule
