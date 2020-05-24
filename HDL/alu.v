/*************************************************************************
 *
 *       Unitat aritmetica i logica (ALU)
 *
 *       Paramtres:
 *           DATA_WIDTH : Amplada del bus de dades
 *
 *       Entrada:
 *           i_data0 : Operand A
 *           i_data1 : Operand B
 *           i_op    : Operacio a realitzar
 *
 *       Sortida:
 *           o_data  : Resultat de l'operacio
 *
 *************************************************************************/
 
 
 /* verilator lint_off DECLFILENAME */

 `include "alu.vh"
 
 
 module alu
#(
    parameter DATA_WIDTH = 16)
(
    input logic [DATA_WIDTH-1:0] i_data0,
    input logic [DATA_WIDTH-1:0] i_data1,
    output logic [DATA_WIDTH-1:0] o_data,
    input logic [3:0] i_op);
    
    logic [DATA_WIDTH-1:0] outAdd;
    logic [DATA_WIDTH-1:0] outAnd;
    logic [DATA_WIDTH-1:0] outOr;
    logic [DATA_WIDTH-1:0] outXor;
    
    alu_add #(
        .DATA_WIDTH(DATA_WIDTH)) 
    alu_add_0(
        .i_data0(i_data0), 
        .i_data1(i_data1), 
        .o_data(outAdd));
        
    alu_and #(
        .DATA_WIDTH(DATA_WIDTH)) 
    alu_and_0(
        .i_data0(i_data0), 
        .i_data1(i_data1), 
        .o_data(outAnd));
        
    alu_or #(
        .DATA_WIDTH(DATA_WIDTH)) 
    alu_or_0(
        .i_data0(i_data0), 
        .i_data1(i_data1), 
        .o_data(outOr));
        
    alu_xor #(
        .DATA_WIDTH(DATA_WIDTH)) 
    alu_xor_0(
        .i_data0(i_data0), 
        .i_data1(i_data1), 
        .o_data(outXor));

    always_comb begin
        case (i_op) 
            `ALU_OP_A    : o_data = i_data0;
            `ALU_OP_B    : o_data = i_data1;
            `ALU_OP_AaddB: o_data = outAdd;
            `ALU_OP_AandB: o_data = outAnd;
            `ALU_OP_AorB : o_data = outOr;
            `ALU_OP_AxorB: o_data = outXor;
            `ALU_OP_notA : o_data = ~i_data0;
            `ALU_OP_AeqB : o_data = i_data0 == i_data1 ? {DATA_WIDTH{1'b1}} : {DATA_WIDTH{1'b0}};
            `ALU_OP_AgtB : o_data = i_data0 > i_data1 ? {DATA_WIDTH{1'b1}} : {DATA_WIDTH{1'b0}};
            `ALU_OP_BshlA: o_data = i_data1 << i_data0;
            `ALU_OP_BshrA: o_data = i_data1 >> i_data0;
            `ALU_OP_Ainc : o_data = i_data0 - {DATA_WIDTH{1'b1}};
            `ALU_OP_Adec : o_data = i_data0 + {DATA_WIDTH{1'b1}};
            default      : o_data = 0;
        endcase
    end

endmodule
    
    
module alu_add
#(
    parameter DATA_WIDTH = 16)
(
    input [DATA_WIDTH-1:0] i_data0,
    input [DATA_WIDTH-1:0] i_data1,
    output [DATA_WIDTH-1:0] o_data);
    
    assign o_data = i_data0 + i_data1;
    
endmodule
    
    
module alu_and
#(
    parameter DATA_WIDTH = 16)
(
    input [DATA_WIDTH-1:0] i_data0,
    input [DATA_WIDTH-1:0] i_data1,
    output [DATA_WIDTH-1:0] o_data);
    
    assign o_data = i_data0 & i_data1;
    
endmodule

    
module alu_or
#(
    parameter DATA_WIDTH = 16)
(
    input [DATA_WIDTH-1:0] i_data0,
    input [DATA_WIDTH-1:0] i_data1,
    output [DATA_WIDTH-1:0] o_data);
    
    assign o_data = i_data0 | i_data1;
    
endmodule
    
    
module alu_xor
#(
    parameter DATA_WIDTH = 16)
(
    input [DATA_WIDTH-1:0] i_data0,
    input [DATA_WIDTH-1:0] i_data1,
    output [DATA_WIDTH-1:0] o_data);
    
    assign o_data = i_data0 ^ i_data1;
    
endmodule
