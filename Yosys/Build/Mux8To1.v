module Mux8To1 (
	i_Select,
	i_Input0,
	i_Input1,
	i_Input2,
	i_Input3,
	i_Input4,
	i_Input5,
	i_Input6,
	i_Input7,
	o_Output
);
	parameter WIDTH = 32;
	input wire [2:0] i_Select;
	input wire [WIDTH - 1:0] i_Input0;
	input wire [WIDTH - 1:0] i_Input1;
	input wire [WIDTH - 1:0] i_Input2;
	input wire [WIDTH - 1:0] i_Input3;
	input wire [WIDTH - 1:0] i_Input4;
	input wire [WIDTH - 1:0] i_Input5;
	input wire [WIDTH - 1:0] i_Input6;
	input wire [WIDTH - 1:0] i_Input7;
	output reg [WIDTH - 1:0] o_Output;
	always @(*)
		case (i_Select)
			3'b000: o_Output = i_Input0;
			3'b001: o_Output = i_Input1;
			3'b010: o_Output = i_Input2;
			3'b011: o_Output = i_Input3;
			3'b100: o_Output = i_Input4;
			3'b101: o_Output = i_Input5;
			3'b110: o_Output = i_Input6;
			3'b111: o_Output = i_Input7;
		endcase
endmodule
