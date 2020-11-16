// verilator lint_off IMPORTSTAR
import types::*;


module Decoder_RV32I (

    input  logic [31:0] i_Inst, // La instruccio a decodificar
    
    output logic [6:0]  o_OP,   // El codi d'operacio
    output logic [4:0]  o_RS1,  // El registre font 1 (rs1)
    output logic [4:0]  o_RS2,  // El registre fomt 2 (rs2)
    output logic [4:0]  o_RD,   // El reguistre de destinacio  (rd)
    
    output logic [4:0]  o_SH,   // El valor de desplaçament de bits (shamt)
    output logic [31:0] o_IMM   // El valor inmediat
);


    // Evalua el valor inmediat de la instruccio
    //
    always_comb begin 
        unique case (i_Inst[6:0])
            OpCode_AUIPC:
                o_IMM = {i_Inst[31:12], 12'b0};
                
            OpCode_BRANCH: 
                o_IMM = {{20{i_Inst[31]}}, i_Inst[7], i_Inst[30:25], i_Inst[11:8], 1'b0};
            
            OpCode_JAL: 
                o_IMM = {{12{i_Inst[31]}}, i_Inst[19:12], i_Inst[20], i_Inst[30:21], 1'b0};
            
            OpCode_JALR,
            OpCode_OP_IMM,
            OpCode_LOAD:
                o_IMM = {{20{i_Inst[31]}}, i_Inst[31:20]};
            
            OpCode_STORE: 
                o_IMM = {{20{i_Inst[31]}}, i_Inst[31:25], i_Inst[11:7]};
                           
            default: 
                o_IMM = 0;
        endcase
    end
    
    // Evalua el desplaçament de bits de la instruccio
    //
    assign o_SH = i_Inst[24:20];
    
    // Evalua els registres de la instruccio
    //
    assign o_RS1 = i_Inst[19:15];
    assign o_RS2 = i_Inst[24:20];
    assign o_RD  = i_Inst[11:7];        

    // Evalua el codi d'operacio
    //
    assign o_OP = i_Inst[6:0];

endmodule
