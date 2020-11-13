// verilator lint_off IMPORTSTAR
import types::*;


// verilator lint_off UNUSED
module Controller_RV32I (

    input  logic [31:0] i_Inst,        // La instruccio
    
    output logic        o_MemWrEnable, // Habilita erscriptura en la memoria
    
    output logic        o_IsJump,      // Indica que es un salt incondicional
    output logic        o_IsBranch,    // Indica que es una bifurcacio condicional

    output AluOp        o_AluControl,  // Selecciona l'operacio en la ALU
    output logic        o_AluSrcB,     // Selecciona l'operand B de la ALU

    output logic        o_RegWrEnable, // Habilita l'escriptura en els registres
    output logic        o_MemToReg);   // Selecciona les dades per escriure en el registre
    
    logic IsIlegal;
    logic IsADD;
    logic IsADDI;
    logic IsAND;
    logic IsANDI;
    logic IsAUIPC;
    logic IsBGE;
    logic IsBGEU;
    logic IsBLT;
    logic IsBLTU;
    logic IsBEQ;
    logic IsBNE;
    logic IsJAL;
    logic IsJALR;
    logic IsLUI;
    logic IsLW;
    logic IsOR;
    logic IsORI;
    logic IsSLL;
    logic IsSLLI;
    logic IsSLT;
    logic IsSLTI;
    logic IsSLTIU;
    logic IsSLTU;
    logic IsSRA;
    logic IsSRAI;
    logic IsSRL;
    logic IsSRLI;
    logic IsSUB;
    logic IsSW;
    logic IsXOR;
    logic IsXORI;
          
    always_comb begin    
    
        IsIlegal = 0;
        
        IsADD   = 0;
        IsADDI  = 0;
        IsAND   = 0;
        IsANDI  = 0;
        IsAUIPC = 0;
        IsBEQ   = 0;
        IsBGEU  = 0;
        IsBGE   = 0;
        IsBLT   = 0;
        IsBLTU  = 0;
        IsBNE   = 0;
        IsJAL   = 0;
        IsJALR  = 0;
        IsLUI   = 0;
        IsLW    = 0;
        IsOR    = 0;
        IsORI   = 0;
        IsSLL   = 0;
        IsSLLI  = 0;
        IsSLT   = 0;
        IsSLTI  = 0;
        IsSLTIU = 0;
        IsSLTU  = 0;
        IsSRA   = 0;
        IsSRAI  = 0;
        IsSRL   = 0;
        IsSRLI  = 0;
        IsSUB   = 0;
        IsSW    = 0;
        IsXOR   = 0;
        IsXORI  = 0;
        
        case (i_Inst[6:0]) 
            OpCode_LUI:   IsLUI = 1;
            
            OpCode_AUIPC: IsAUIPC = 1;
            
            OpCode_JAL:   IsJAL = 1;

            OpCode_JALR:  IsJALR = 1;
            
            OpCode_LOAD:
                case (i_Inst[14:12])
                    3'b010:  IsLW = 1;
                    default: IsIlegal = 1;
                endcase
                
            OpCode_STORE :
                case (i_Inst[14:12])
                    3'b010:  IsSW = 1;
                    default: IsIlegal = 1;
                endcase
                
            OpCode_OP: 
                case (i_Inst[14:12])
                    3'b000: if (i_Inst[30]) IsSUB = 1;
                            else IsADD = 1;                            
                    3'b001: IsSLL = 1;
                    3'b010: IsSLT = 1;
                    3'b011: IsSLTU = 1;
                    3'b100: IsXOR = 1;
                    3'b101: if (i_Inst[30]) IsSRA = 1;
                            else IsSRL = 1;
                    3'b110: IsOR = 1;
                    3'b111: IsAND = 1;
                endcase
                
            OpCode_OP_IMM:
                case (i_Inst[14:12]) 
                    3'b000: IsADDI = 1;
                    3'b001: IsSLL = 1;
                    3'b010: IsSLTI = 1;
                    3'b011: IsSLTIU = 1;
                    3'b100: IsXORI = 1;
                    3'b101: if (i_Inst[30]) IsSRLI = 1; 
                            else IsSRAI = 1;
                    3'b110: IsORI = 1;
                    3'b111: IsANDI = 1;
                endcase
            
            OpCode_BRANCH: 
                case (i_Inst[14:12]) 
                    3'b000:  IsBEQ = 1;
                    3'b001:  IsBNE = 1;
                    3'b100:  IsBLT = 1;
                    3'b101:  IsBGE = 1;
                    3'b110:  IsBLTU = 1;
                    3'b111:  IsBGEU = 1;
                    default: IsIlegal = 1;
                endcase
                
            default: IsIlegal = 1;
        endcase
    end
       
    always_comb begin
        case (i_Inst[6:0])
            OpCode_LOAD,
            OpCode_STORE:
                o_AluControl = AluOp_ADD;
                
            OpCode_OP: 
                case (i_Inst[14:12])
                    3'b000: if (i_Inst[30]) o_AluControl = AluOp_SUB;
                            else o_AluControl = AluOp_ADD;                            
                    3'b001: IsSLL = 1;
                    3'b010: IsSLT = 1;
                    3'b011: IsSLTU = 1;
                    3'b100: o_AluControl = AluOp_XOR;
                    3'b101: if (i_Inst[30]) o_AluControl = AluOp_SRA;
                            else o_AluControl = AluOp_SRL;
                    3'b110: o_AluControl = AluOp_OR;
                    3'b111: o_AluControl = AluOp_AND;
                endcase
                
            OpCode_OP_IMM: 
                case (i_Inst[14:12])
                    3'b000: o_AluControl = AluOp_ADD;
                    3'b001: IsSLL = 1;
                    3'b010: IsSLTI = 1;
                    3'b011: IsSLTIU = 1;
                    3'b100: o_AluControl = AluOp_XOR;
                    3'b101: if (i_Inst[30]) o_AluControl = AluOp_SRL; 
                            else o_AluControl = AluOp_SRA;
                    3'b110: o_AluControl = AluOp_OR;
                    3'b111: o_AluControl = AluOp_AND;
                endcase
                
            default:
                o_AluControl = AluOp_Unknown;
        endcase
    end
        
    logic IsTypeR;
    always_comb begin
        IsTypeR = IsADD | IsSUB | IsSLL | IsSLT | IsSLTU | IsXOR | IsSRL |
            IsSRA | IsOR | IsAND;

        o_AluSrcB     = IsLW | IsSW;
        o_MemWrEnable = IsSW;
        o_RegWrEnable = IsTypeR | IsLW ;
        o_MemToReg    = IsLW;
        
        o_IsBranch    = IsBEQ | IsBNE | IsBLT | IsBGE | IsBLTU | IsBGEU;
        o_IsJump      = IsJAL | IsJALR;
    end

endmodule
