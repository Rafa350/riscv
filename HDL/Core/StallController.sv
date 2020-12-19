module StallController
#(
    parameter REG_WIDTH = 5)
(
    input  logic [REG_WIDTH-1:0] i_instRS1,
    input  logic [REG_WIDTH-1:0] i_instRS2,
    input  logic                 i_EX_IsLoad,
    input  logic [REG_WIDTH-1:0] i_EX_RegAddr,
    input  logic                 i_MEM_IsLoad,
    input  logic [REG_WIDTH-1:0] i_MEM_RegAddr,

    output logic                 o_bubble);


    // No cal evaluar RegWrEnable ja que esta implicit en i_IsLoad

    assign o_bubble =
        (i_EX_IsLoad & 
            ((i_instRS1 != 5'b0) & ((i_instRS1 == i_EX_RegAddr) | (i_instRS1 == i_MEM_RegAddr)))) |
            
        (i_MEM_IsLoad &
            ((i_instRS2 != 5'b0) & ((i_instRS2 == i_EX_RegAddr) | (i_instRS2 == i_MEM_RegAddr))));

endmodule
