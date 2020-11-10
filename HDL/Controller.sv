 // verilator lint_off IMPORTSTAR 
 // verilator lint_off UNUSED
 // verilator lint_off UNDRIVEN 
 
import types::*;


module Controller
(
    input  logic   i_Clock,
    input  logic   i_Reset,
    
    input  InstOp  i_InstOp,
    input  InstFn  i_InstFn,
    
    output logic   o_MemWrEnable,
    
    output logic   o_IsBranch,
    output logic   o_IsJump,

    output AluOp   o_AluControl,
    output logic   o_AluSrcB,

    output logic   o_RegWrEnable,
    output logic   o_RegDst,
    output logic   o_MemToReg);
    
    logic IsTypeR;
    logic IsADDI;
    logic IsLW;
    logic IsSW;
    logic IsJ;
    logic IsBEQ;
    
    always_comb begin
    
        // Decodificacio de les instruccions
        //
        IsTypeR = i_InstOp == InstOp_Type_R;       
        IsADDI  = i_InstOp == InstOp_ADDI;
        IsLW    = i_InstOp == InstOp_LW;
        IsSW    = i_InstOp == InstOp_SW;
        IsJ     = i_InstOp == InstOp_J;
        IsBEQ   = i_InstOp == InstOp_BEQ;
    
        // Evalua el codi d'operacio de la ALU
        //
        if (IsTypeR)
            case (i_InstFn)
                InstFn_ADD: o_AluControl = AluOp_ADD;
                InstFn_AND: o_AluControl = AluOp_AND;
                default:    o_AluControl = AluOp_Unknown;
            endcase
        else
            case (i_InstOp)
                InstOp_ADDI: o_AluControl = AluOp_ADD;
                InstOp_LW:   o_AluControl = AluOp_ADD;
                InstOp_SW:   o_AluControl = AluOp_ADD;
                default:     o_AluControl = AluOp_Unknown;
            endcase
    
        // Evalua les señals de control
        //
        o_AluSrcB     = IsADDI | IsLW | IsSW;
        o_MemWrEnable = IsSW;
        o_RegWrEnable = IsTypeR | IsLW | IsADDI;
        o_RegDst      = IsTypeR;
        o_MemToReg    = IsLW;
        o_IsBranch    = IsBEQ;
        o_IsJump      = IsJ;
        
    end
        
endmodule
