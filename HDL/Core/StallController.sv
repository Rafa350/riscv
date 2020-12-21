module StallController
    import Types::*;
(
    input  RegAddr i_instRS1,
    input  RegAddr i_instRS2,
    input  logic   i_EX_IsLoad,
    input  RegAddr i_EX_RegAddr,
    input  logic   i_MEM_IsLoad,
    input  RegAddr i_MEM_RegAddr,

    output logic   o_bubble);


    // No cal evaluar RegWrEnable ja que esta implicit en i_IsLoad

    assign o_bubble =
        (i_EX_IsLoad &
            ((i_instRS1 != RegAddr'(0)) & ((i_instRS1 == i_EX_RegAddr) | (i_instRS1 == i_MEM_RegAddr)))) |

        (i_MEM_IsLoad &
            ((i_instRS2 != RegAddr'(0)) & ((i_instRS2 == i_EX_RegAddr) | (i_instRS2 == i_MEM_RegAddr))));

endmodule
