module ForwardController
#(
    parameter REG_WIDTH = 5)
(
    input  logic [REG_WIDTH-1:0] i_RequiredRS1,
    input  logic [REG_WIDTH-1:0] i_RequiredRS2,
    input  logic [REG_WIDTH-1:0] i_EXMEM_RegWrAddr,
    input  logic                 i_EXMEM_RegWrEnable,
    input  logic [REG_WIDTH-1:0] i_MEMWB_RegWrAddr,
    input  logic                 i_MEMWB_RegWrEnable,

    output logic [1:0]           o_RS1Sel,
    output logic [1:0]           o_RS2Sel);
    

    logic RS1InEXMEM;
    logic RS1InMEMWB;
    logic RS2InEXMEM;
    logic RS2InMEMWB;
    
    assign RS1InEXMEM = (i_RequiredRS1 == i_EXMEM_RegWrAddr) & (i_EXMEM_RegWrAddr != 0) & i_EXMEM_RegWrEnable;
    assign RS1InMEMWB = (i_RequiredRS1 == i_MEMWB_RegWrAddr) & (i_MEMWB_RegWrAddr != 0) & i_MEMWB_RegWrEnable;
    
    assign RS2InEXMEM = (i_RequiredRS2 == i_EXMEM_RegWrAddr) & (i_EXMEM_RegWrAddr != 0) & i_EXMEM_RegWrEnable;
    assign RS2InMEMWB = (i_RequiredRS2 == i_MEMWB_RegWrAddr) & (i_MEMWB_RegWrAddr != 0) & i_MEMWB_RegWrEnable;

    always_comb begin
        unique casez ({RS1InEXMEM, RS1InMEMWB})
            2'b1?  : o_RS1Sel = 2'b01;
            2'b01  : o_RS1Sel = 2'b10;
            default: o_RS1Sel = 2'b00;
        endcase

        unique casez ({RS2InEXMEM, RS2InMEMWB})
            2'b1?  : o_RS2Sel = 2'b01;
            2'b01  : o_RS2Sel = 2'b10;
            default: o_RS2Sel = 2'b00;
        endcase

    end
    
endmodule