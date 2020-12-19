module ForwardController
    import Types::*;
(
    input  RegAddr     i_instRS1,
    input  RegAddr     i_instRS2,
    input  RegAddr     i_EX_RegWrAddr,
    input  logic       i_EX_RegWrEnable,
    input  logic [1:0] i_EX_RegWrDataSel,
    input  RegAddr     i_MEM_RegWrAddr,
    input  logic       i_MEM_RegWrEnable,
    input  RegAddr     i_WB_RegWrAddr,
    input  logic       i_WB_RegWrEnable,
    output logic [1:0] o_dataASel,          // Seleccio del valor de RS1
    output logic [1:0] o_dataBSel);         // Seleccio del valor de RS2


    always_comb begin

        if ((i_instRS1 != 5'b0) & (i_instRS1 == i_EX_RegWrAddr) & (i_EX_RegWrDataSel == 2'b00) & i_EX_RegWrEnable)
            o_dataASel = 2'd1;
        else if ((i_instRS1 != 5'b0) & (i_instRS1 == i_MEM_RegWrAddr) & i_MEM_RegWrEnable)
            o_dataASel = 2'd2;
        else if ((i_instRS1 != 5'b0) & (i_instRS1 == i_WB_RegWrAddr) & i_WB_RegWrEnable)
            o_dataASel = 2'd3;
        else
            o_dataASel = 2'd0;

        if ((i_instRS2 != 5'b0) & (i_instRS2 == i_EX_RegWrAddr) & (i_EX_RegWrDataSel == 2'b00) & i_EX_RegWrEnable)
            o_dataBSel = 2'd1;
        else if ((i_instRS2 != 5'b0) & (i_instRS2 == i_MEM_RegWrAddr) & i_MEM_RegWrEnable)
            o_dataBSel = 2'd2;
        else if ((i_instRS2 != 5'b0) & (i_instRS2 == i_WB_RegWrAddr) & i_WB_RegWrEnable)
            o_dataBSel = 2'd3;
        else
            o_dataBSel = 2'd0;
    end

endmodule
