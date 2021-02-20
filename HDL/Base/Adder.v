// -----------------------------------------------------------------------
//
//       Sumador
//
//       Parametres:
//	         WIDTH      :   Amplada del canal de dades en bits
//
//       Entrades:
//           i_operandA : Operand A
//           i_operandB : Operand B
//           i_carry    : Carry/Borrow
//
//       Sortides:
//           o_result   : Resultat de l'operacio
//           o_carry    : Carry/Borrow
//           o_overflow : Indicador de sobrecarrega
//
// -----------------------------------------------------------------------

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


	logic [WIDTH-1:0] add_gCarry;
	logic [WIDTH-1:0] add_pCarry;
	logic [WIDTH-1:0] lac_carry;
	logic             lac_gCarry;
	logic             lac_pCarry;

	generate
		genvar i, j;

		// Sumadors
		//
		for (i = 0; i < WIDTH; i++) begin : BLK1
			Adder_ADD
			add (
				.i_operandA (i_operandA[i]),
				.i_operandB (i_operandB[i]),
				.i_carry    (lac_carry[i]),
				.o_result   (o_result[i]),
				.o_gCarry   (add_gCarry[i]),
				.o_pCarry   (add_pCarry[i]));
		end

		// Generadors de Look-Ahead Carry
		//
		localparam NUM_LEVELS = $clog2(WIDTH);

		for (i = 0; i < NUM_LEVELS; i++) begin : BLK2

            localparam NUM_BITS = WIDTH/(2**i)/2;

			logic [NUM_BITS-1:0] c;
			logic [NUM_BITS-1:0] g;
			logic [NUM_BITS-1:0] p;

			for (j = 0; j < NUM_BITS; j++) begin : BLK3

				if (i == 0) begin
					Adder_LAC lac (
						.i_g ({add_gCarry[j+j+1:j+j]}),
						.i_p ({add_pCarry[j+j+1:j+j]}),
						.o_c ({lac_carry[j+j+1:j+j]}),
						.o_g (BLK2[i].g[j]),
						.o_p (BLK2[i].p[j]),
						.i_c (BLK2[i].c[j]));
				end
				else begin
					Adder_LAC lac (
						.i_g (BLK2[i-1].g[j+j+1:j+j]),
						.i_p (BLK2[i-1].p[j+j+1:j+j]),
						.o_c (BLK2[i-1].c[j+j+1:j+j]),
						.o_g (BLK2[i].g[j]),
						.o_p (BLK2[i].p[j]),
						.i_c (BLK2[i].c[j]));
				end

				if (i == NUM_LEVELS-1) begin
					assign BLK2[i].c[j] = i_carry;
					assign lac_pCarry = BLK2[i].p[0];
					assign lac_gCarry = BLK2[i].g[0];
				end

			end
		end
	endgenerate


    // Evaluacio final
	//
	assign o_carry = lac_gCarry | (lac_pCarry & i_carry);
	assign o_overflow = o_carry ^ lac_carry[WIDTH-1];

 endmodule


module Adder_ADD (
	input  logic i_operandA,
	input  logic i_operandB,
	input  logic i_carry,
	output logic o_result,
	output logic o_pCarry,
	output logic o_gCarry);

 	assign o_gCarry = i_operandA & i_operandB;
	assign o_pCarry = i_operandA ^ i_operandB;
	assign o_result = o_pCarry ^ i_carry;

endmodule


module Adder_LAC (
	input  logic [1:0] i_g,
	input  logic [1:0] i_p,
	output logic [1:0] o_c,
	output logic o_g,
	output logic o_p,
	input  logic i_c
);

	assign o_c[0] = i_c;
	assign o_c[1] = i_g[0] | (i_p[0] & i_c);
	assign o_g    = i_g[1] | (i_p[1] & i_g[0]);
	assign o_p    = i_p[0] & i_p[1];

endmodule