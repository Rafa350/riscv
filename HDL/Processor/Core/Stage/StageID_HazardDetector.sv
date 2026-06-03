module StageID_HazardDetector (
    input  ProcessorDefs::GPRAddr i_instRS1,
    input  ProcessorDefs::GPRAddr i_instRS2,
    input  logic                  i_EX_isValid,
    input  logic                  i_EX_memRdEnable,
    input  ProcessorDefs::GPRAddr i_EX_regAddr,
    input  logic                  i_MEM_isValid,
    input  logic                  i_MEM_memRdEnable,
    input  ProcessorDefs::GPRAddr i_MEM_regAddr,

    output logic   o_hazard);


    // Comprova si el valor d'un registre GPR, encara s'ha de carregar
    // de la memoria.

    assign o_hazard =
        (i_EX_memRdEnable & i_EX_isValid &
            ((i_instRS1 != ProcessorDefs::GPRAddr'(0)) & ((i_instRS1 == i_EX_regAddr) | (i_instRS1 == i_MEM_regAddr)))) |

        (i_MEM_memRdEnable & i_MEM_isValid &
            ((i_instRS2 != ProcessorDefs::GPRAddr'(0)) & ((i_instRS2 == i_EX_regAddr) | (i_instRS2 == i_MEM_regAddr))));

endmodule
