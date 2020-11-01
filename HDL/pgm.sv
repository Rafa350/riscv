module pgm
#(
    parameter ADDR_WIDTH = 32,
    parameter INST_WIDTH = 32)
(   
    input  logic [ADDR_WIDTH-1:0] i_addr,
    output logic [INST_WIDTH-1:0]  o_inst);

    always_comb
        case (i_addr) 
            32'h0  : o_inst = { Inst_LW,  5'd0, 5'd1, 16'd0 }; // LW  $1, 0($0)
            32'h1  : o_inst = { Inst_LW,  5'd0, 5'd2, 16'd1 }; // LW  $2, 1($0)
            32'h2  : o_inst = { Inst_ADD, 5'd3, 5'd1, 5'd2  }; // ADD $3, $1, $2)
            32'h3  : o_inst = { Inst_SW,  5'd0, 5'd3, 16'd3 }; // SW  $3, 2($0)
            default: o_inst = { Inst_J,   26'd0             }; // J   0
        endcase

endmodule