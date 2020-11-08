module mux8
#(
    parameter WIDTH = 32)
(
    input  logic [2:0]       i_Select,
    
    input  logic [WIDTH-1:0] i_Input0,
    input  logic [WIDTH-1:0] i_Input1,
    input  logic [WIDTH-1:0] i_Input2,
    input  logic [WIDTH-1:0] i_Input3,
    input  logic [WIDTH-1:0] i_Input4,
    input  logic [WIDTH-1:0] i_Input5,
    input  logic [WIDTH-1:0] i_Input6,
    input  logic [WIDTH-1:0] i_Input7,
    
    output logic [WIDTH-1:0] o_Output);

    always_comb
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