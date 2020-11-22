module ForwardController
#(
    parameter REG_WIDTH = 5)
(
    input  logic [REG_WIDTH-1:0] i_RequiredRS1,     // Registre sol·licitat RS1
    input  logic [REG_WIDTH-1:0] i_RequiredRS2,     // Registre sol·licitat RS2
    input  logic [REG_WIDTH-1:0] i_T1_RegWrAddr,    // Registre en la etata T + 1
    input  logic                 i_T1_RegWrEnable,  // Pendent d'escriure   
    input  logic [REG_WIDTH-1:0] i_T2_RegWrAddr,    // Registre en la etapa T + 2
    input  logic                 i_T2_RegWrEnable,  // Pendent d'escriure

    output logic [1:0]           o_RS1Sel,          // Seleccio del valor de RS1
    output logic [1:0]           o_RS2Sel);         // Seleccio del valor de RS2
    

    logic RS1InT1;
    logic RS1InT2;
    logic RS2InT1;
    logic RS2InT2;
    
    // Comprova si el valor del registre pendent d'escriure, es present en les etapes
    // posteriors del pipeline.
    
    assign RS1InT1 = (i_RequiredRS1 == i_T1_RegWrAddr) & (i_T1_RegWrAddr != 0) & i_T1_RegWrEnable;
    assign RS1InT2 = (i_RequiredRS1 == i_T2_RegWrAddr) & (i_T2_RegWrAddr != 0) & i_T2_RegWrEnable;
    
    assign RS2InT1 = (i_RequiredRS2 == i_T1_RegWrAddr) & (i_T1_RegWrAddr != 0) & i_T1_RegWrEnable;
    assign RS2InT2 = (i_RequiredRS2 == i_T2_RegWrAddr) & (i_T2_RegWrAddr != 0) & i_T2_RegWrEnable;

    always_comb begin
        unique casez ({RS1InT1, RS1InT2})
            2'b1?  : o_RS1Sel = 2'b01;
            2'b01  : o_RS1Sel = 2'b10;
            default: o_RS1Sel = 2'b00;
        endcase

        unique casez ({RS2InT1, RS2InT2})
            2'b1?  : o_RS2Sel = 2'b01;
            2'b01  : o_RS2Sel = 2'b10;
            default: o_RS2Sel = 2'b00;
        endcase

    end
    
endmodule