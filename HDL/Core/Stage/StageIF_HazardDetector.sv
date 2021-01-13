module StageIF_HazardDetector
(
    input  logic i_MEM_memRdEnable,
    input  logic i_MEM_memWrEnable,

    output logic o_hazard);


    assign o_hazard = i_MEM_memRdEnable | i_MEM_memWrEnable;

endmodule