module HazardDetector
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

    output logic                 o_IFID_Stall,
    output logic                 o_IDEX_Flush,
    output logic                 o_EXMEM_Flush,
    output logic                 o_MEMWB_Flush);
    
    assign o_IFID_Stall = 0;
    assign o_IDEX_FLush = 0;
    assign o_EXMEM_FLush = 0;
    assign o_MEMWB_FLush = 0;

endmodule
