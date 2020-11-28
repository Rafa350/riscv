module ForwardController
#(
    parameter REG_WIDTH = 5)
(
    input  logic [REG_WIDTH-1:0] i_InstRS1,
    input  logic [REG_WIDTH-1:0] i_InstRS2,
    input  logic [REG_WIDTH-1:0] i_EX_RegWrAddr,
    input  logic                 i_EX_RegWrEnable,
    input  logic [1:0]           i_EX_RegWrDataSel,
    input  logic [REG_WIDTH-1:0] i_MEM_RegWrAddr,
    input  logic                 i_MEM_RegWrEnable,
    input  logic [REG_WIDTH-1:0] i_WB_RegWrAddr,
    input  logic                 i_WB_RegWrEnable,
    

    output logic [1:0]           o_DataASel,          // Seleccio del valor de RS1
    output logic [1:0]           o_DataBSel);         // Seleccio del valor de RS2


    always_comb begin
    
        if ((i_InstRS1 != 5'b0) & (i_InstRS1 == i_EX_RegWrAddr) & (i_EX_RegWrDataSel == 2'b00) & i_EX_RegWrEnable)
            o_DataASel = 2'd1;
        else if ((i_InstRS1 != 5'b0) & (i_InstRS1 == i_MEM_RegWrAddr) & i_MEM_RegWrEnable)
            o_DataASel = 2'd2;
        else if ((i_InstRS1 != 5'b0) & (i_InstRS1 == i_WB_RegWrAddr) & i_WB_RegWrEnable)
            o_DataASel = 2'd3;
        else
            o_DataASel = 2'd0;
         
        if ((i_InstRS2 != 5'b0) & (i_InstRS2 == i_EX_RegWrAddr) & (i_EX_RegWrDataSel == 2'b00) & i_EX_RegWrEnable)
            o_DataBSel = 2'd1;
        else if ((i_InstRS2 != 5'b0) & (i_InstRS2 == i_MEM_RegWrAddr) & i_MEM_RegWrEnable)
            o_DataBSel = 2'd2;
        else if ((i_InstRS2 != 5'b0) & (i_InstRS2 == i_WB_RegWrAddr) & i_WB_RegWrEnable)
            o_DataBSel = 2'd3;
        else
            o_DataBSel = 2'd0;
    end

endmodule