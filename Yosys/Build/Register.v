module Register (
	i_Clock,
	i_Reset,
	i_WrEnable,
	i_WrData,
	o_RdData
);
	parameter WIDTH = 32;
	parameter INIT = 32'd0;
	input wire i_Clock;
	input wire i_Reset;
	input wire i_WrEnable;
	input wire [WIDTH - 1:0] i_WrData;
	output wire [WIDTH - 1:0] o_RdData;
	reg [WIDTH - 1:0] Data;
	initial Data = INIT;
	always @(posedge i_Clock)
		case ({i_Reset, i_WrEnable})
			2'b00: Data <= Data;
			2'b01: Data <= i_WrData;
			2'b10: Data <= INIT;
			2'b11: Data <= INIT;
		endcase
	assign o_RdData = (i_Reset ? INIT : Data);
endmodule
