module StallController
(
    input  logic i_IF_hazard,     // Indica hazard en IF
    input  logic i_ID_hazard,     // Indiza hazard en ID
    input  logic i_EX_hazard,     // Indica hazard en EX
    input  logic i_MEM_hazard,    // Indica hazard en MEM
    input  logic i_WB_hazard,     // Indica hazard en WB
    input  logic i_IFID_isValid,  // Indica valid en IFID
    input  logic i_IDEX_isValid,  // Indica valid en IDEX
    input  logic i_EXMEM_isValid, // Indica valid en EXMEM
    input  logic i_MEMWB_isValid, // Indica valid en MEMWB

    output logic o_IFID_stall,
    output logic o_IDEX_stall,
    output logic o_IDEX_flush,
    output logic o_EXMEM_stall,
    output logic o_EXMEM_flush,
    output logic o_MEMWB_flush);


    // Control del pipeline IFID
    // Cas especial al estar integrat el PC amb IFID
    //
    assign o_IFID_stall = i_ID_hazard | i_IF_hazard | (o_IDEX_stall & i_IFID_isValid);

    // Control del pipeline IDEX
    //
    assign o_IDEX_stall = i_EX_hazard | (o_EXMEM_stall & i_IDEX_isValid);
    assign o_IDEX_flush = o_IFID_stall;

    // Control del pipeline EXMEM
    //
    assign o_EXMEM_stall = i_MEM_hazard;
    assign o_EXMEM_flush = o_IDEX_stall;

    // Control del pipeline MEMWB
    //
    assign o_MEMWB_flush = o_EXMEM_stall;


endmodule
