// Intruccions tipus J (Salts)
// LOAD:     1001 r1 r2 address  : LOAD r1 [r2]
// STORE:    1001 r1 r2 address  : STORE 

// Instruccions tipus R (Registres)
// ALU:      1100 xxxx r1 r2 rd

// Instruccions tipus I (Immediat)
// IMM:      1110 code r value


module ctl 
(
    input  logic         i_clk,
    input  logic         i_rst,
    
    input  logic  [15:0] i_inst,
    
    output logic [3:0]   o_alu_op,
    output logic         o_regs_wr_enable,
    output logic         o_mem_wr_enable,
    output logic         o_alu_data2_selector,
    output logic         o_reg_wr_index_selector,
    output logic         o_regs_rd_data_selector);
    

endmodule
