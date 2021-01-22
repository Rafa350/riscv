module StageIF_HazardDetector
(
    input  logic i_MEM_isValid,
    input  logic i_MEM_memRdEnable,
    input  logic i_MEM_memWrEnable,

    output logic o_hazard);

    // Detecta accessos a la memoria en el stage MEM

    assign o_hazard = i_MEM_isValid & (i_MEM_memRdEnable | i_MEM_memWrEnable);

endmodule