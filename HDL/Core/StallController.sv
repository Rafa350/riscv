module StallController
(
    input  logic i_IF_hazard,   // Indica hazard en IF
    input  logic i_ID_hazard,   // Indiza hazard en ID
    input  logic i_EX_hazard,   // Indica hazard en EX
    input  logic i_MEM_hazard,  // Indica hazard en MEM

    output logic o_IFID_stall,
    output logic o_IDEX_stall,
    output logic o_IDEX_flush,
    output logic o_EXMEM_stall,
    output logic o_EXMEM_flush,
    output logic o_MEMWB_flush);


    assign o_IFID_stall = i_ID_hazard | i_IF_hazard | o_IDEX_stall;

    assign o_IDEX_stall = i_EX_hazard | o_EXMEM_stall;
    assign o_IDEX_flush = o_IFID_stall;

    assign o_EXMEM_stall = i_MEM_hazard;
    assign o_EXMEM_flush = o_IDEX_stall;

    assign o_MEMWB_flush = o_EXMEM_stall;


endmodule