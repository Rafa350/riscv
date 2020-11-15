module Mux2To1 (
	i_Select,
	i_Input0,
	i_Input1,
	o_Output
);
	parameter WIDTH = 32;
	input wire i_Select;
	input wire [WIDTH - 1:0] i_Input0;
	input wire [WIDTH - 1:0] i_Input1;
	output wire [WIDTH - 1:0] o_Output;
	assign o_Output = (i_Select ? i_Input1 : i_Input0);
endmodule
