module Mux4To1 (
	i_Select,
	i_Input0,
	i_Input1,
	i_Input2,
	i_Input3,
	o_Output
);
	parameter WIDTH = 32;
	input wire [1:0] i_Select;
	input wire [WIDTH - 1:0] i_Input0;
	input wire [WIDTH - 1:0] i_Input1;
	input wire [WIDTH - 1:0] i_Input2;
	input wire [WIDTH - 1:0] i_Input3;
	output reg [WIDTH - 1:0] o_Output;
	always @(*)
		case (i_Select)
			2'b00: o_Output = i_Input0;
			2'b01: o_Output = i_Input1;
			2'b10: o_Output = i_Input2;
			2'b11: o_Output = i_Input3;
		endcase
endmodule
