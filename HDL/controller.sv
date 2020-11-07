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
    
    output logic   o_MemWrite,
    
    output logic   o_is_branch,
    output logic   o_is_jump,

    output AluOp   o_AluControl,
    output logic   o_AluSrc,

    output logic   o_RegWrite,
    output logic   o_RegDst,
    output logic   o_MemToReg);
    
    logic is_type_R;
    logic is_ADDI;
    logic is_LW;
    logic is_SW;
    logic is_J;
    logic is_BEQ;
    
    always_comb begin
    
        // Decodificacio de les instruccions
        //
        is_type_R = i_inst_op == InstOp_Type_R;       
        is_ADDI   = i_inst_op == InstOp_ADDI;
        is_LW     = i_inst_op == InstOp_LW;
        is_SW     = i_inst_op == InstOp_SW;
        is_J      = i_inst_op == InstOp_J;
        is_BEQ    = i_inst_op == InstOp_BEQ;
    
        // Evalua el codi d'operacio de la ALU
        //
        if (is_type_R)
            case (i_inst_fn)
                InstFn_ADD: o_AluControl = AluOp_ADD;
                InstFn_AND: o_AluControl = AluOp_AND;
                default:    o_AluControl = AluOp_Unknown;
            endcase
        else
            case (i_inst_op)
                InstOp_ADDI: o_AluControl = AluOp_ADD;
                InstOp_LW:   o_AluControl = AluOp_ADD;
                InstOp_SW:   o_AluControl = AluOp_ADD;
                default:     o_AluControl = AluOp_Unknown;
            endcase
    
        // Evalua les señals de control
        //
        o_AluSrc    = is_ADDI | is_LW | is_SW;
        o_MemWrite  = is_SW;
        o_RegWrite  = is_type_R | is_LW | is_ADDI;
        o_RegDst    = is_type_R;
        o_MemToReg  = is_LW;
        o_is_branch = is_BEQ;
        o_is_jump   = is_J;
        
    end
        
endmodule
