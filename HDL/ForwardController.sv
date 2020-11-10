// verilator lint_off UNUSED
module ForwardController(
    input  logic [4:0] i_IDFwdInstRS,
    input  logic [4:0] i_IDFwdInstRT,
    input  logic [4:0] i_EXFwdWriteReg,
    input  logic [4:0] i_MEMFwdWriteReg,

    output logic [1:0] o_DataASelect,
    output logic [1:0] o_DataBSelect);

    assign o_DataASelect = 0;
    assign o_DataBSelect = 0;
    
endmodule