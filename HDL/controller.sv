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
    
    output logic   o_BranchRequest,

    output AluOp   o_AluControl,
    output logic   o_AluSrc,

    output logic   o_RegWrite,
    output logic   o_RegDst,
    output logic   o_MemToReg);
    
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
    assign o_AluSrc = is_ADDI | is_LW | is_SW;
    always_comb
        if (is_rtype)
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
    
    assign o_MemWrite = is_SW;

    assign o_RegWrite = is_rtype | is_LW | is_ADDI;
    assign o_RegDst = is_rtype;
    assign o_MemToReg = is_LW;
    assign o_BranchRequest = 0;
        
endmodule
