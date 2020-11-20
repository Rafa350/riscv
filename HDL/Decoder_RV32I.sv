// verilator lint_off IMPORTSTAR
import types::*;


module Decoder_RV32I
#(
    parameter REG_WIDTH = 5)
 (

    input  logic [31:0]          i_Inst, // La instruccio a decodificar
    
    output logic [6:0]           o_OP,   // El codi d'operacio
    output logic [REG_WIDTH-1:0] o_RS1,  // El registre font 1 (rs1)
    output logic [REG_WIDTH-1:0] o_RS2,  // El registre fomt 2 (rs2)
    output logic [REG_WIDTH-1:0] o_RD,   // El registre de destinacio  (rd)
    
    output logic [31:0]          o_IMM); // El valor inmediat


    // Evalua el valor inmediat de la instruccio
    //
    always_comb begin
        unique casez ({i_Inst[31:25], i_Inst[14:12], i_Inst[6:0]}) 
            /* AUIPC  */ 17'b???????_???_0110111,
            /* LUI    */ 17'b???????_???_0010111: o_IMM = {i_Inst[31:12], 12'b0};
                
            /* JAL    */ 17'b???????_???_1101111: o_IMM = {{12{i_Inst[31]}}, i_Inst[19:12], i_Inst[20], i_Inst[30:21], 1'b0};
                
            /* Branch */ 17'b???????_???_1100011: o_IMM = {{20{i_Inst[31]}}, i_Inst[7], i_Inst[30:25], i_Inst[11:8], 1'b0};
                
            /* SLLI   */ 17'b0000000_001_0010011,
            /* SRLI   */ 17'b0000000_101_0010011,
            /* SRAI   */ 17'b0100000_101_0010011: o_IMM = {{27{1'b0}}, i_Inst[24:20]}; // Sempre positiu
                
            /* Load   */ 17'b???????_???_0000011,
            /* ADDI   */ 17'b???????_000_0010011,
            /* SLTI   */ 17'b???????_010_0010011,
            /* SLTIU  */ 17'b???????_011_0010011,
            /* XORI   */ 17'b???????_100_0010011,
            /* ORI    */ 17'b???????_110_0010011,
            /* ANDI   */ 17'b???????_111_0010011,
            /* JALR   */ 17'b???????_000_1100111: o_IMM = {{20{i_Inst[31]}}, i_Inst[31:20]};
            
            /* Store  */ 17'b???????_???_0100011: o_IMM = {{20{i_Inst[31]}}, i_Inst[31:25], i_Inst[11:7]};
            
            default                             : o_IMM = 0;
        endcase
    end
       
    // Evalua els registres de la instruccio
    //
    assign o_RS1 = i_Inst[REG_WIDTH+14:15];
    assign o_RS2 = i_Inst[REG_WIDTH+19:20];
    assign o_RD  = i_Inst[REG_WIDTH+6:7];        

    // Evalua el codi d'operacio
    //
    assign o_OP = i_Inst[6:0];

endmodule
