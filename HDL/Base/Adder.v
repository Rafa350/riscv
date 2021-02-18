module Adder
#(
    parameter WIDTH = 32)
(
	input  logic [WIDTH-1:0] i_operandA,  // Operand A
    input  logic [WIDTH-1:0] i_operandB,  // Operand B
	input  logic             i_carry,     // Carry/Borrow d'entrada
    
	output logic [WIDTH-1:0] o_result,    // Resultat
	output logic             o_carry,     // Carray/Borrow
	output logic             o_overflow); // Sobrecarrega
    

    localparam LAC_LEVEL = $clog2(WIDTH);
    

	logic [WIDTH-1:0] carry, gCarry, pCarry;
	logic gout, pout;

	ADD #(
        .WIDTH (WIDTH))
    add(
		.i_operandA (i_operandA), 
		.i_operandB (i_operandB), 
		.i_carry    (carry), 
		.o_result   (o_result), 
		.o_gCarry   (gCarry), 
		.o_pCarry   (pCarry));
        
    generate 
    if (LAC_LEVEL == 6) 
        LAC64 lac(
            .i_carry(i_carry),
            .i_gCarry({{64-WIDTH{1'd0}}, gCarry}),
            .i_pCarry({{64-WIDTH{1'd0}}, pCarry}),
            .o_carry(carry),
            .gout(gout),
            .pout(pout));
    else if (LAC_LEVEL == 5)
        LAC32 lac(
            .i_carry(i_carry),
            .i_gCarry({{32-WIDTH{1'd0}}, gCarry}),
            .i_pCarry({{32-WIDTH{1'd0}}, pCarry}),
            .o_carry(carry),
            .gout(gout),
            .pout(pout));
    else if (LAC_LEVEL == 4)
        LAC16 lac(
            .i_carry(i_carry),
            .i_gCarry({{16-WIDTH{1'd0}}, gCarry}),
            .i_pCarry({{16-WIDTH{1'd0}}, pCarry}),
            .o_carry(carry),
            .gout(gout),
            .pout(pout));
    else if (LAC_LEVEL == 3)
        LAC8 lac(
            .i_carry(i_carry),
            .i_gCarry({{8-WIDTH{1'd0}}, gCarry}),
            .i_pCarry({{8-WIDTH{1'd0}}, pCarry}),
            .o_carry(carry),
            .gout(gout),
            .pout(pout));
    else if (LAC_LEVEL == 2)
        LAC4 lac(
            .i_carry(i_carry),
            .i_gCarry({{4-WIDTH{1'd0}}, gCarry}),
            .i_pCarry({{4-WIDTH{1'd0}}, pCarry}),
            .o_carry(carry),
            .gout(gout),
            .pout(pout));
    endgenerate

	assign o_carry = gout | (pout & i_carry);
	assign o_overflow = o_carry ^ carry[WIDTH-1];

 endmodule

 
/*************************************************************************
 *
 *       Sumador elemental de N bits amb sortides P i G
 *
 *       Entrades:
 *           i_operandA : Operand A
 *           i_operandB : Operand B
 *           i_carry    : Carry
 *
 *       Sortides:
 *           o_result   : Resultat
 *           o_gCarry   : Generated carry
 *           o_pCarry   : Propagated carry
 *
 *       Parametres:
 *           DATA_WIDTH : Amplada del bus de dades
 *
 *************************************************************************/

 module ADD
 #(
    parameter WIDTH = 32)
 (
	input  logic [WIDTH-1:0] i_operandA, 
    input  logic [WIDTH-1:0] i_operandB, 
    input  logic [WIDTH-1:0] i_carry,
	
    output logic [WIDTH-1:0] o_result, 
    output logic [WIDTH-1:0] o_gCarry, 
    output logic [WIDTH-1:0] o_pCarry);

 	assign o_gCarry = i_operandA & i_operandB;
	assign o_pCarry = i_operandA ^ i_operandB;
	assign o_result = o_pCarry ^ i_carry;
     
 endmodule

 
/*************************************************************************
 *
 *       Look-Ahead Carry
 *
 *       Entrades:
 *           i_carry  : Carry
 *           i_pCarry : Carry propagat
 *           i_gCarry : Carry generat
 *
 *       Sortides:
 *           o_carry  : Carry
 *           o_gCarry : Carry generat
 *           o_pCarry : Carry propagat
 *
 ************************************************************************/

module LAC2(
	input logic i_carry,
	input logic [1:0] i_gCarry, 
    input logic [1:0] i_pCarry,
	
    output logic [1:0] o_carry,
	output logic gout, 
    output logic pout);

	assign o_carry[0] = i_carry;
	assign o_carry[1] = i_gCarry[0] | (i_pCarry[0] & i_carry);
	assign gout = i_gCarry[1] | (i_pCarry[1] & i_gCarry[0]);
	assign pout = i_pCarry[1] & i_pCarry[0];

endmodule

module LAC4(
	input logic i_carry,
	input logic [3:0] i_gCarry, i_pCarry,
	
    output logic [3:0] o_carry,
	output logic gout, pout);
	
	logic [1:0] cint, gint, pint;

	LAC2 lower(
		.i_carry(cint[0]),
		.i_gCarry(i_gCarry[1:0]),
		.i_pCarry(i_pCarry[1:0]),
		.o_carry(o_carry[1:0]),
		.gout(gint[0]),
		.pout(pint[0]));

	LAC2 upper(
		.i_carry(cint[1]),
		.i_gCarry(i_gCarry[3:2]),
		.i_pCarry(i_pCarry[3:2]),
		.o_carry(o_carry[3:2]),
		.gout(gint[1]),
		.pout(pint[1]));

	LAC2 root(
		.i_carry(i_carry),
		.i_gCarry(gint),
		.i_pCarry(pint),
		.o_carry(cint),
		.gout(gout),
		.pout(pout));
	
endmodule

module LAC8(
	input logic i_carry,
	input logic [7:0] i_gCarry, i_pCarry,
	
    output logic [7:0] o_carry,
	output logic gout, pout);

	logic [1:0] cint, gint, pint;

	LAC4 lower(
		.i_carry(cint[0]),
		.i_gCarry(i_gCarry[3:0]),
		.i_pCarry(i_pCarry[3:0]),
		.o_carry(o_carry[3:0]),
		.gout(gint[0]),
		.pout(pint[0]));

	LAC4 upper(
		.i_carry(cint[1]),
		.i_gCarry(i_gCarry[7:4]),
		.i_pCarry(i_pCarry[7:4]),
		.o_carry(o_carry[7:4]),
		.gout(gint[1]),
		.pout(pint[1]));

	LAC2 root(
		.i_carry(i_carry),
		.i_gCarry(gint),
		.i_pCarry(pint),
		.o_carry(cint),
		.gout(gout),
		.pout(pout));

endmodule

module LAC16(
	input logic i_carry,
	input logic [15:0] i_gCarry, i_pCarry,
	
    output logic [15:0] o_carry,
	output logic gout, pout);

	logic [1:0] cint, gint, pint;

	LAC8 lower(
		.i_carry(cint[0]),
		.i_gCarry(i_gCarry[7:0]),
		.i_pCarry(i_pCarry[7:0]),
		.o_carry(o_carry[7:0]),
		.gout(gint[0]),
		.pout(pint[0]));

	LAC8 upper(
		.i_carry(cint[1]),
		.i_gCarry(i_gCarry[15:8]),
		.i_pCarry(i_pCarry[15:8]),
		.o_carry(o_carry[15:8]),
		.gout(gint[1]),
		.pout(pint[1]));

	LAC2 root(
		.i_carry(i_carry),
		.i_gCarry(gint),
		.i_pCarry(pint),
		.o_carry(cint),
		.gout(gout),
		.pout(pout));

endmodule

module LAC32(
	input logic i_carry,
	input logic [31:0] i_gCarry, i_pCarry,
	
    output logic [31:0] o_carry,
	output logic gout, pout);

	logic [1:0] cint, gint, pint;

	LAC16 lower(
		.i_carry(cint[0]),
		.i_gCarry(i_gCarry[15:0]),
		.i_pCarry(i_pCarry[15:0]),
		.o_carry(o_carry[15:0]),
		.gout(gint[0]),
		.pout(pint[0]));

	LAC16 upper(
		.i_carry(cint[1]),
		.i_gCarry(i_gCarry[31:16]),
		.i_pCarry(i_pCarry[31:16]),
		.o_carry(o_carry[31:16]),
		.gout(gint[1]),
		.pout(pint[1]));

	LAC2 root(
		.i_carry(i_carry),
		.i_gCarry(gint),
		.i_pCarry(pint),
		.o_carry(cint),
		.gout(gout),
		.pout(pout));

endmodule

module LAC64(
	input logic i_carry,
	input logic [63:0] i_gCarry, i_pCarry,
	
    output logic [63:0] o_carry,
	output logic gout, pout);

	logic [1:0] cint, gint, pint;

	LAC32 lower(
		.i_carry(cint[0]),
		.i_gCarry(i_gCarry[31:0]),
		.i_pCarry(i_pCarry[31:0]),
		.o_carry(o_carry[31:0]),
		.gout(gint[0]),
		.pout(pint[0]));

	LAC32 upper(
		.i_carry(cint[1]),
		.i_gCarry(i_gCarry[63:32]),
		.i_pCarry(i_pCarry[63:32]),
		.o_carry(o_carry[63:32]),
		.gout(gint[1]),
		.pout(pint[1]));

	LAC2 root(
		.i_carry(i_carry),
		.i_gCarry(gint),
		.i_pCarry(pint),
		.o_carry(cint),
		.gout(gout),
		.pout(pout));

endmodule
