// verilator lint_off IMPORTSTAR
import types::*;


// verilator lint_off UNUSED
module Controller_RV32I (

    input  logic [31:0] i_Inst,          // La instruccio

    output logic        o_MemWrEnable,   // Habilita erscriptura en la memoria

    output logic        o_IsJump,        // Indica que es un salt incondicional
    output logic        o_IsBranch,      // Indica que es una bifurcacio condicional

    output AluOp        o_AluControl,    // Selecciona l'operacio en la ALU
    output logic        o_OperandBSel,   // Selecciona l'operand B de la ALU

    output logic        o_RegWrEnable,   // Habilita l'escriptura en els registres
    output logic [1:0]  o_DataToRegSel); // Selecciona les dades per escriure en el registre


    // -----------------------------------------------------------------------
    //
    //                     OperandBSel
    //                     |     DataToRegSel
    //                     |     |     RegWrEnable
    //                     |     |     |     MemWrEnable
    //                     |     |     |     |     IsBranch
    //                     |     |     |     |     |     IsJump
    //                     |     |     |     |     |     |     AluControl
    //                     |     |     |     |     |     |     |
    //
    localparam DP_ADD   = {1'b0, 2'b00, 1'b1, 1'b0, 1'b0, 1'b0, AluOp_ADD    };
    localparam DP_ADDI  = {1'b1, 2'b00, 1'b1, 1'b0, 1'b0, 1'b0, AluOp_ADD    };
    localparam DP_AND   = {1'b0, 2'b00, 1'b1, 1'b0, 1'b0, 1'b0, AluOp_AND    };
    localparam DP_ANDI  = {1'b1, 2'b00, 1'b1, 1'b0, 1'b0, 1'b0, AluOp_AND    };
    localparam DP_AUIPC = {1'b0, 2'b00, 1'b0, 1'b0, 1'b0, 1'b0, AluOp_Unknown};
   
    localparam DP_BEQ   = {1'b0, 2'b00, 1'b0, 1'b0, 1'b1, 1'b0, AluOp_Unknown};
    localparam DP_BGE   = {1'b0, 2'b00, 1'b0, 1'b0, 1'b1, 1'b0, AluOp_Unknown};
    localparam DP_BGEU  = {1'b0, 2'b00, 1'b0, 1'b0, 1'b1, 1'b0, AluOp_Unknown};
    localparam DP_BLT   = {1'b0, 2'b00, 1'b0, 1'b0, 1'b1, 1'b0, AluOp_Unknown};
    localparam DP_BLTU  = {1'b0, 2'b00, 1'b0, 1'b0, 1'b1, 1'b0, AluOp_Unknown};
    localparam DP_BNE   = {1'b0, 2'b00, 1'b0, 1'b0, 1'b1, 1'b0, AluOp_Unknown};

    localparam DP_JAL   = {1'b0, 2'b00, 1'b0, 1'b0, 1'b0, 1'b1, AluOp_Unknown};
    localparam DP_JALR  = {1'b0, 2'b00, 1'b0, 1'b0, 1'b0, 1'b1, AluOp_Unknown};

    localparam DP_LUI   = {1'b0, 2'b00, 1'b0, 1'b0, 1'b0, 1'b0, AluOp_Unknown};
    localparam DP_LB    = {1'b1, 2'b01, 1'b1, 1'b0, 1'b0, 1'b0, AluOp_ADD    };
    localparam DP_LH    = {1'b1, 2'b01, 1'b1, 1'b0, 1'b0, 1'b0, AluOp_ADD    };
    localparam DP_LW    = {1'b1, 2'b01, 1'b1, 1'b0, 1'b0, 1'b0, AluOp_ADD    };

    localparam DP_OR    = {1'b0, 2'b00, 1'b1, 1'b0, 1'b0, 1'b0, AluOp_OR     };
    localparam DP_ORI   = {1'b0, 2'b00, 1'b0, 1'b0, 1'b0, 1'b0, AluOp_OR     };

    localparam DP_SB    = {1'b1, 2'b00, 1'b0, 1'b1, 1'b0, 1'b0, AluOp_ADD    };
    localparam DP_SH    = {1'b1, 2'b00, 1'b0, 1'b1, 1'b0, 1'b0, AluOp_ADD    };
    localparam DP_SLT   = {1'b0, 2'b00, 1'b1, 1'b0, 1'b0, 1'b0, AluOp_SLT    };
    localparam DP_SLTI  = {1'b1, 2'b00, 1'b1, 1'b0, 1'b0, 1'b0, AluOp_SLT    };
    localparam DP_SLTIU = {1'b1, 2'b00, 1'b1, 1'b0, 1'b0, 1'b0, AluOp_SLTU   };
    localparam DP_SLTU  = {1'b0, 2'b00, 1'b1, 1'b0, 1'b0, 1'b0, AluOp_SLTU   };
    localparam DP_SUB   = {1'b0, 2'b00, 1'b1, 1'b0, 1'b0, 1'b0, AluOp_ADD    };
    localparam DP_SW    = {1'b1, 2'b00, 1'b0, 1'b1, 1'b0, 1'b0, AluOp_ADD    };

    localparam DP_XOR   = {1'b0, 2'b00, 1'b1, 1'b0, 1'b0, 1'b0, AluOp_XOR    };
    localparam DP_XORI  = {1'b1, 2'b00, 1'b1, 1'b0, 1'b0, 1'b0, AluOp_AND    };


    logic [11:0] dp;
    assign o_AluControl   = AluOp'(dp[4:0]);
    assign o_IsJump       = dp[5];
    assign o_IsBranch     = dp[6];
    assign o_MemWrEnable  = dp[7];
    assign o_RegWrEnable  = dp[8];
    assign o_DataToRegSel = dp[10:9];
    assign o_OperandBSel  = dp[11];
    
    
    always_comb begin
        unique casez ({i_Inst[31:25], i_Inst[14:12], i_Inst[6:0]})
            /*  ADD   */ 17'b0000000_000_0110011: dp = DP_ADD;
            /*  ADDI  */ 17'b???????_000_0010011: dp = DP_ADDI;
            /*  AND   */ 17'b0000000_111_0110011: dp = DP_AND;
            /*  ANDI  */ 17'b???????_111_0010011: dp = DP_ANDI;
            /*  AUIPC */ 17'b???????_???_0010111: dp = DP_AUIPC;

            /*  BEQ   */ 17'b???????_000_1100011: dp = DP_BEQ;
            /*  BGE   */ 17'b???????_101_1100011: dp = DP_BGE;
            /*  BGEU  */ 17'b???????_111_1100011: dp = DP_BGEU;
            /*  BLT   */ 17'b???????_100_1100011: dp = DP_BLT;
            /*  BLTU  */ 17'b???????_110_1100011: dp = DP_BLTU;
            /*  BNE   */ 17'b???????_001_1100011: dp = DP_BNE;

            /*  JAL   */ 17'b???????_???_1101111: dp = DP_JAL;
            /*  JALR  */ 17'b???????_000_1100111: dp = DP_JALR;

            /*  LUI   */ 17'b???????_???_0110111: dp = DP_LUI;
            /*  LB    */ 17'b???????_000_0000011: dp = DP_LB;
            /*  LH    */ 17'b???????_001_0000011: dp = DP_LH;
            /*  LW    */ 17'b???????_010_0000011: dp = DP_LW;

            /*  OR    */ 17'b0000000_110_0110011: dp = DP_OR;
            /*  ORI   */ 17'b???????_110_0010011: dp = DP_ORI;

            /*  SB    */ 17'b???????_000_0100011: dp = DP_SB;
            /*  SH    */ 17'b???????_001_0100011: dp = DP_SH;
            /*  SLT   */ 17'b0000000_010_0110011: dp = DP_SLT;
            /*  SLTI  */ 17'b???????_010_0010011: dp = DP_SLTI;
            /*  SLTIU */ 17'b???????_011_0010011: dp = DP_SLTIU;
            /*  SLTU  */ 17'b0000000_011_0110011: dp = DP_SLTU;
            /*  SUB   */ 17'b0100000_000_0110011: dp = DP_SUB;
            /*  SW    */ 17'b???????_010_0100011: dp = DP_SW;

            /*  XOR   */ 17'b0000000_100_0110011: dp = DP_XOR;
            /*  XORI  */ 17'b???????_100_0010011: dp = DP_XORI;

            default: dp = 0;
        endcase
    end

endmodule
