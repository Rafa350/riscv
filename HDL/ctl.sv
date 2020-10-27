// Intruccions tipus J (Salts)
// LOAD:     1001 r1 r2 address  : LOAD r1 [r2]
// STORE:    1001 r1 r2 address  : STORE 

// Instruccions tipus R (Registres)
// ALU:      1100 xxxx r1 r2 rd

// Instruccions tipus I (Immediat)
// IMM:      1110 code r value


module ctl 
(
    input logic[15:0] i_inst,
    
    output logic [2:0] o_reg_waddr,
    output logic [2:0] o_reg_raddr1,
    output logic [2:0] o_reg_raddr2,
    output logic o_reg_we,
    
    output logic o_mem_we,
    output logic o_mem_addr,
    
    output logic o_lit,
    output logic [3:0] o_alu_op);
    

endmodule
