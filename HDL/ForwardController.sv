// verilator lint_off UNUSED
module ForwardController
#(
    parameter REG_WIDTH = 5)
(
    input  logic [REG_WIDTH-1:0] i_RequiredRS1,
    input  logic [REG_WIDTH-1:0] i_RequiredRS2,
    input  logic [REG_WIDTH-1:0] i_RegEXWrAddr,
    input  logic                 i_RegEXWrEnable,
    input  logic [REG_WIDTH-1:0] i_RegMEMWrAddr,
    input  logic                 i_RegMEMWrEnable,

    output logic [1:0]           o_RS1Sel,
    output logic [1:0]           o_RS2Sel);
    

    logic RS1InEX;
    logic RS1InMEM;
    logic RS2InEX;
    logic RS2InMEM;
    
    assign RS1InEX  = i_RequiredRS1 == i_RegEXWrAddr;
    assign RS1InMEM = i_RequiredRS1 == i_RegMEMWrAddr;
    assign RS2InEX  = i_RequiredRS2 == i_RegEXWrAddr;
    assign RS2InMEM = i_RequiredRS2 == i_RegMEMWrAddr;

    always_comb begin
        unique casez ({RS1InEX, RS1InMEM, i_RegEXWrEnable, i_RegMEMWrEnable})
            4'b??00: o_RS1Sel = 2'b00;
            4'b1?1?: o_RS1Sel = 2'b01;
            4'b01?1: o_RS1Sel = 2'b10;
            default: o_RS1Sel = 2'b00;
        endcase

        unique casez ({RS2InEX, RS2InMEM, i_RegEXWrEnable, i_RegMEMWrEnable})
            4'b??00: o_RS2Sel = 2'b00;
            4'b1?1?: o_RS2Sel = 2'b01;
            4'b01?1: o_RS2Sel = 2'b10;
            default: o_RS2Sel = 2'b00;
        endcase

    end
    
endmodule