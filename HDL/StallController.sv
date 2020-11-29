module StallController
#(
    parameter REG_WIDTH = 5)
(
    input  logic [REG_WIDTH-1:0] i_InstRS1,
    input  logic [REG_WIDTH-1:0] i_InstRS2,
    logic  input                 i_EX_IsLoad,
    input  logic [REG_WIDTH-1:0] i_EX_RegAddr,
    logic  input                 i_MEM_IsLoad,
    input  logic [REG_WIDTH-1:0] i_MEM_RegAddr,

    output logic                 o_Stall);


    // No cal evaluar RegWrEnable ja que esta implicit en i_IsLoad

    always_comb begin
        if (i_IDEX_IsLoad & (i_InstRS1 != 0) & (i_InstRS1 == i_IDEX_RegAddr))
            o_Stall = 1'b1;
            
        else if (i_EXMEM_IsLoad & (i_InstRS1 != 0) & (i_InstRS1 == i_EXMEM_RegAddr))
            o_Stall = 1'b1;
    
        else if (i_IDEX_IsLoad & (i_InstRS2 != 0) & (i_InstRS2 == i_IDEX_RegAddr))
            o_Stall = 1'b1;
            
        else if (i_EXMEM_IsLoad & (i_InstRS2 != 0) & (i_InstRS2 == i_EXMEM_RegAddr))
            o_Stall = 1'b1;
            
        else
            o_Stall = 1'b0;

endmodule
