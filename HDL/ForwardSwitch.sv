module ForwardSwitch
#(
    parameter DATA_WIDTH = 32)
(
    input  logic [DATA_WIDTH-1:0] i_DataA,
    input  logic [DATA_WIDTH-1:0] i_DataB,
    input  logic [DATA_WIDTH-1:0] i_DataT1,
    input  logic [DATA_WIDTH-1:0] i_DataT2,
    
    input [1:0]                   i_DataASelect,
    input [1:0]                   i_DataBSelect,

    output logic [DATA_WIDTH-1:0] o_DataA,
    output logic [DATA_WIDTH-1:0] o_DataB);


    // verilator lint_off PINMISSING
    Mux4To1 #(
        .WIDTH (DATA_WIDTH))
    Sel1 (
        .i_Select (i_DataASelect),
        .i_Input0 (i_DataA),
        .i_Input1 (i_DataT1),
        .i_Input2 (i_DataT2),
        .o_Output (o_DataA));
    // verilator lint_on PINMISSING

    // verilator lint_off PINMISSING
    Mux4To1 #(
        .WIDTH (DATA_WIDTH))
    Sel2 (
        .i_Select (i_DataBSelect),
        .i_Input0 (i_DataB),
        .i_Input1 (i_DataT1),
        .i_Input2 (i_DataT2),
        .o_Output (o_DataB));
    // verilator lint_on PINMISSING


endmodule