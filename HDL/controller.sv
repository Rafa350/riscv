 // verilator lint_off IMPORTSTAR 
 // verilator lint_off UNUSED
 // verilator lint_off UNDRIVEN 
 
import types::*;


module controller
(
    input  logic   i_clk,
    input  logic   i_rst,
    
    input  InstOp  i_inst_op,
    input  InstFn  i_inst_fn,
    
    output logic   o_mem_wr_enable,
    
    output logic   o_pc_branch,
    output logic   o_pc_jump,

    output AluOp   o_alu_op,
    output logic   o_alu_data2_selector,

    output logic   o_regs_wr_enable,
    output logic   o_regs_wr_index_selector,
    output logic   o_regs_wr_data_selector);
    
    logic is_rtype;
    logic is_ADDI;
    logic is_LW;
    logic is_SW;
    
    // Decodificacio de les instruccions
    //
    assign is_rtype = i_inst_op == InstOp_RType;       
    assign is_ADDI = (i_inst_op == InstOp_ADDI);
    assign is_LW   = (i_inst_op == InstOp_LW);
    assign is_SW   = (i_inst_op == InstOp_SW);
    
    // Actualitzacio de les senyals de control
    //
    assign o_alu_data2_selector = is_ADDI | is_LW | is_SW;
    always_comb
        if (is_rtype)
            case (i_inst_fn)
                InstFn_ADD: o_alu_op = AluOp_ADD;
                InstFn_AND: o_alu_op = AluOp_AND;
                default:    o_alu_op = AluOp_Unknown;
            endcase
        else
            case (i_inst_op)
                InstOp_ADDI: o_alu_op = AluOp_ADD;
                InstOp_LW:   o_alu_op = AluOp_ADD;
                InstOp_SW:   o_alu_op = AluOp_ADD;
                default:     o_alu_op = AluOp_Unknown;
            endcase
    
    assign o_mem_wr_enable = is_SW;

    assign o_regs_wr_enable = is_rtype | is_LW | is_ADDI;
    assign o_regs_wr_index_selector = is_rtype;
    assign o_regs_wr_data_selector = is_LW;
        
endmodule
