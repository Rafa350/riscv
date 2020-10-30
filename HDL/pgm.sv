module pgm
#(
    parameter ADDR_WIDTH = 16,
    parameter INST_WIDTH = 32)
(   
    input  logic [ADDR_WIDTH-1:0] i_addr,
    output logic [INST_WIDTH-1:0]  o_inst);

    always_comb
        case (i_addr) 
            32'h0  : o_inst = { 32'b_100011_00000_00001_0000000000000000};     // LW  $1, 0($0)
            32'h1  : o_inst = { 32'b_100011_00000_00010_0000000000000001};     // LW  $2, 1($0)
            32'h2  : o_inst = { 32'b_000000_00001_00010_00011_00000_100000};   // ADD $3, $1, $2)
            32'h3  : o_inst = { 32'b_101011_00000_00011_0000000000000011};     // SW  $·, 2($0)
            default: o_inst = { 32'b_010001_00000000000000000000000000};       // J   0
        endcase

endmodule