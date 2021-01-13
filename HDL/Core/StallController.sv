module StallController
(
    input  logic i_reset,

    input  logic i_IF_hazard,
    input  logic i_ID_hazard,
    input  logic i_EX_hazard,
    input  logic i_MEM_hazard,

    output logic o_IFID_stall,
    output logic o_IFID_flush,
    output logic o_IDEX_stall,
    output logic o_IDEX_flush,
    output logic o_EXMEM_stall,
    output logic o_EXMEM_flush,
    output logic o_MEMWB_stall,
    output logic o_MEMWB_flush);


    assign o_IFID_stall = o_IDEX_stall | i_ID_hazard;
    assign o_IFID_flush = i_IF_hazard;

    assign o_IDEX_stall = o_EXMEM_stall | i_EX_hazard;
    assign o_IDEX_flush = i_ID_hazard;

    assign o_EXMEM_stall = o_MEMWB_stall | i_MEM_hazard;
    assign o_EXMEM_flush = i_EX_hazard;

    assign o_MEMWB_stall = 0;
    assign o_MEMWB_flush = i_MEM_hazard;


endmodule