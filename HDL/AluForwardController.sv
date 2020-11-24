module AluForwardController
#(
    parameter REG_WIDTH = 5)
(
    input  logic [REG_WIDTH-1:0] i_InstRS1,           // Parametre RS1 de la instruccio
    input  logic [REG_WIDTH-1:0] i_InstRS2,           // Parametre RS2 de la instruccio
    input  logic [REG_WIDTH-1:0] i_EXMEM_RegWrAddr,   // Registre en la etapa T + 1
    input  logic                 i_EXMEM_RegWrEnable, // Pendent d'escriure   
    input  logic [REG_WIDTH-1:0] i_MEMWB_RegWrAddr,   // Registre en la etapa T + 2
    input  logic                 i_MEMWB_RegWrEnable, // Pendent d'escriure

    output logic [1:0]           o_DataASel,          // Seleccio del valor de RS1
    output logic [1:0]           o_DataBSel);         // Seleccio del valor de RS2
    

    logic RS1InT1;
    logic RS1InT2;
    logic RS2InT1;
    logic RS2InT2;
    
    // Comprova si el valor del registre pendent d'escriure, es present en les etapes
    // posteriors del pipeline.
    
    assign RS1InT1 = (i_InstRS1 == i_EXMEM_RegWrAddr) & (i_EXMEM_RegWrAddr != 0) & i_EXMEM_RegWrEnable;
    assign RS1InT2 = (i_InstRS1 == i_MEMWB_RegWrAddr) & (i_MEMWB_RegWrAddr != 0) & i_MEMWB_RegWrEnable;
    
    assign RS2InT1 = (i_InstRS2 == i_EXMEM_RegWrAddr) & (i_EXMEM_RegWrAddr != 0) & i_EXMEM_RegWrEnable;
    assign RS2InT2 = (i_InstRS2 == i_MEMWB_RegWrAddr) & (i_MEMWB_RegWrAddr != 0) & i_MEMWB_RegWrEnable;

    always_comb begin
        unique casez ({RS1InT1, RS1InT2})
            2'b1?  : o_DataASel = 2'b01;
            2'b01  : o_DataASel = 2'b10;
            default: o_DataASel = 2'b00;
        endcase

        unique casez ({RS2InT1, RS2InT2})
            2'b1?  : o_DataBSel = 2'b01;
            2'b01  : o_DataBSel = 2'b10;
            default: o_DataBSel = 2'b00;
        endcase

    end
    
endmodule