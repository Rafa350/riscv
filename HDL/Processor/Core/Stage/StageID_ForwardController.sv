module StageID_ForwardController
    import CoreDefs::*;
(
    input  GPRAddr     i_instRS1,
    input  GPRAddr     i_instRS2,
    input  logic       i_EX_isValid,
    input  GPRAddr     i_EX_regWrAddr,
    input  logic       i_EX_regWrEnable,
    input  WrDataSel   i_EX_regWrDataSel,
    input  logic       i_MEM_isValid,
    input  GPRAddr     i_MEM_regWrAddr,
    input  logic       i_MEM_regWrEnable,
    input  logic       i_WB_isValid,
    input  GPRAddr     i_WB_regWrAddr,
    input  logic       i_WB_regWrEnable,
    output logic [1:0] o_dataRS1Sel,      // Seleccio del valor de RS1
    output logic [1:0] o_dataRS2Sel);     // Seleccio del valor de RS2


    always_comb begin

        if ((i_instRS1 != GPRAddr'(0)) & (i_instRS1 == i_EX_regWrAddr) & (i_EX_regWrDataSel == WrDataSel_CALC) & i_EX_regWrEnable & i_EX_isValid)
            o_dataRS1Sel = 2'd1;
        else if ((i_instRS1 != GPRAddr'(0)) & (i_instRS1 == i_MEM_regWrAddr) & i_MEM_regWrEnable & i_MEM_isValid)
            o_dataRS1Sel = 2'd2;
        else if ((i_instRS1 != GPRAddr'(0)) & (i_instRS1 == i_WB_regWrAddr) & i_WB_regWrEnable & i_WB_isValid)
            o_dataRS1Sel = 2'd3;
        else
            o_dataRS1Sel = 2'd0;

        if ((i_instRS2 != GPRAddr'(0)) & (i_instRS2 == i_EX_regWrAddr) & (i_EX_regWrDataSel == WrDataSel_CALC) & i_EX_regWrEnable & i_EX_isValid)
            o_dataRS2Sel = 2'd1;
        else if ((i_instRS2 != GPRAddr'(0)) & (i_instRS2 == i_MEM_regWrAddr) & i_MEM_regWrEnable & i_MEM_isValid)
            o_dataRS2Sel = 2'd2;
        else if ((i_instRS2 != GPRAddr'(0)) & (i_instRS2 == i_WB_regWrAddr) & i_WB_regWrEnable & i_WB_isValid)
            o_dataRS2Sel = 2'd3;
        else
            o_dataRS2Sel = 2'd0;
    end

endmodule
