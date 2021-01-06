module HazardDetector
    import Types::*;
(
    input  RegAddr i_instRS1,
    input  RegAddr i_instRS2,
    input  logic   i_EX_memRdEnable,
    input  RegAddr i_EX_regAddr,
    input  logic   i_MEM_memRdEnable,
    input  RegAddr i_MEM_regAddr,

    output logic   o_bubble);


    // Comprova si el valor d'un registre, encara s'ha de carregar
    // de la memoria.

    assign o_bubble =
        (i_EX_memRdEnable &
            ((i_instRS1 != RegAddr'(0)) & ((i_instRS1 == i_EX_regAddr) | (i_instRS1 == i_MEM_regAddr)))) |

        (i_MEM_memRdEnable &
            ((i_instRS2 != RegAddr'(0)) & ((i_instRS2 == i_EX_regAddr) | (i_instRS2 == i_MEM_regAddr))));

endmodule
