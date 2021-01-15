module StageIF_HazardDetector
(
    input  logic i_MEM_memRdEnable,
    input  logic i_MEM_memWrEnable,

    output logic o_hazard);

    // Detecta accessos a la memoria en el stage MEM

    assign o_hazard = 1'b0; //i_MEM_memRdEnable | i_MEM_memWrEnable;

endmodule