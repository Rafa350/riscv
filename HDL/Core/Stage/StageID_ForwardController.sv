module StageID_ForwardController
    import Types::*;
(
    input  RegAddr     i_instRS1,
    input  RegAddr     i_instRS2,
    input  logic       i_EX_isValid,
    input  RegAddr     i_EX_regWrAddr,
    input  logic       i_EX_regWrEnable,
    input  logic [1:0] i_EX_regWrDataSel,
    input  logic       i_MEM_isValid,
    input  RegAddr     i_MEM_regWrAddr,
    input  logic       i_MEM_regWrEnable,
    input  logic       i_WB_isValid,
    input  RegAddr     i_WB_regWrAddr,
    input  logic       i_WB_regWrEnable,
    output logic [1:0] o_dataASel,          // Seleccio del valor de RS1
    output logic [1:0] o_dataBSel);         // Seleccio del valor de RS2


    always_comb begin

        if ((i_instRS1 != RegAddr'(0)) & (i_instRS1 == i_EX_regWrAddr) & (i_EX_regWrDataSel == 2'b00) & i_EX_regWrEnable & i_EX_isValid)
            o_dataASel = 2'd1;
        else if ((i_instRS1 != RegAddr'(0)) & (i_instRS1 == i_MEM_regWrAddr) & i_MEM_regWrEnable & i_MEM_isValid)
            o_dataASel = 2'd2;
        else if ((i_instRS1 != RegAddr'(0)) & (i_instRS1 == i_WB_regWrAddr) & i_WB_regWrEnable & i_WB_isValid)
            o_dataASel = 2'd3;
        else
            o_dataASel = 2'd0;

        if ((i_instRS2 != RegAddr'(0)) & (i_instRS2 == i_EX_regWrAddr) & (i_EX_regWrDataSel == 2'b00) & i_EX_regWrEnable & i_EX_isValid)
            o_dataBSel = 2'd1;
        else if ((i_instRS2 != RegAddr'(0)) & (i_instRS2 == i_MEM_regWrAddr) & i_MEM_regWrEnable & i_MEM_isValid)
            o_dataBSel = 2'd2;
        else if ((i_instRS2 != RegAddr'(0)) & (i_instRS2 == i_WB_regWrAddr) & i_WB_regWrEnable & i_WB_isValid)
            o_dataBSel = 2'd3;
        else
            o_dataBSel = 2'd0;
    end

endmodule
