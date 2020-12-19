module DatapathController
    import Types::*;
(
    input  Inst        i_inst,          // La instruccio
    input  logic       i_isEQ,          // Indica A == B
    input  logic       i_isLT,          // Indica A < B

    output logic       o_memWrEnable,   // Habilita erscriptura en la memoria

    output logic [1:0] o_pcNextSel,     // Selecciona el seguent valor del PC

    output AluOp       o_aluControl,    // Selecciona l'operacio en la ALU
    output logic [1:0] o_operandASel,
    output logic [1:0] o_operandBSel,   // Selecciona l'operand B de la ALU

    output logic       o_regWrEnable,   // Habilita l'escriptura en els registres
    output logic [1:0] o_regWrDataSel); // Selecciona les dades per escriure en el registre

    localparam  asREG = 2'b00;           // Selecciona el valor del registre
    localparam  asPC  = 2'b01;           // Selecciona el valor del PC
    localparam  asV0  = 2'b10;           // Selecciona el valor 0

    localparam  bsREG = 2'b00;           // Selecciona el valor del registre
    localparam  bsIMM = 2'b01;           // Selecciona el valor IMM
    localparam  bsV4  = 2'b10;           // Selecciona el valor 4

    localparam  wrALU = 2'b00;           // Escriu el valor de la ALU
    localparam  wrMEM = 2'b01;           // Escriu el valor de la memoria
    localparam  wrPC4 = 2'b10;           // Escriu el valor de PC+4

    localparam  pcPP4 = 2'b00;           // PC = PC + 4
    localparam  pcOFS = 2'b01;           // PC = PC + offset
    localparam  pcIND = 2'b10;           // PC = [RS1] + offset

    localparam  ENA   = 1'b1;
    localparam  DIS   = 1'b0;


    // -----------------------------------------------------------------------
    //                     OperandASel
    //                     |      OperandBSel
    //                     |      |      RegWrDataSel
    //                     |      |      |      RegWrEnable
    //                     |      |      |      |     MemWrEnable
    //                     |      |      |      |     |     PCNextSel
    //                     |      |      |      |     |     |
    //                     |      |      |      |     |     |      AluControl
    //                     |      |      |      |     |     |      |
    //                     -----  -----  -----  ----  ----  -----  -------------
    localparam DP_ADD   = {asREG, bsREG, wrALU, 1'b1, 1'b0, pcPP4, AluOp_ADD    };
    localparam DP_ADDI  = {asREG, bsIMM, wrALU, 1'b1, 1'b0, pcPP4, AluOp_ADD    };
    localparam DP_AND   = {asREG, bsREG, wrALU, 1'b1, 1'b0, pcPP4, AluOp_AND    };
    localparam DP_ANDI  = {asREG, bsIMM, wrALU, 1'b1, 1'b0, pcPP4, AluOp_AND    };
    localparam DP_AUIPC = {asPC,  bsIMM, wrALU, 1'b1, 1'b0, pcPP4, AluOp_ADD    };

    localparam DP_BEQ   = {asREG, bsREG, wrALU, 1'b0, 1'b0, pcOFS, AluOp_Unknown};
    localparam DP_BGE   = {asREG, bsREG, wrALU, 1'b0, 1'b0, pcOFS, AluOp_Unknown};
    localparam DP_BGEU  = {asREG, bsREG, wrALU, 1'b0, 1'b0, pcOFS, AluOp_Unknown};
    localparam DP_BLT   = {asREG, bsREG, wrALU, 1'b0, 1'b0, pcOFS, AluOp_Unknown};
    localparam DP_BLTU  = {asREG, bsREG, wrALU, 1'b0, 1'b0, pcOFS, AluOp_Unknown};
    localparam DP_BNE   = {asREG, bsREG, wrALU, 1'b0, 1'b0, pcOFS, AluOp_Unknown};

    localparam DP_JAL   = {asREG, bsREG, wrPC4, 1'b1, 1'b0, pcOFS, AluOp_Unknown};
    localparam DP_JALR  = {asREG, bsREG, wrPC4, 1'b1, 1'b0, pcIND, AluOp_Unknown};

    localparam DP_LUI   = {asV0,  bsIMM, wrALU, 1'b1, 1'b0, pcPP4, AluOp_ADD    };
    localparam DP_LB    = {asREG, bsIMM, wrMEM, 1'b1, 1'b0, pcPP4, AluOp_ADD    };
    localparam DP_LH    = {asREG, bsIMM, wrMEM, 1'b1, 1'b0, pcPP4, AluOp_ADD    };
    localparam DP_LW    = {asREG, bsIMM, wrMEM, 1'b1, 1'b0, pcPP4, AluOp_ADD    };

    localparam DP_OR    = {asREG, bsREG, wrALU, 1'b1, 1'b0, pcPP4, AluOp_OR     };
    localparam DP_ORI   = {asREG, bsREG, wrALU, 1'b0, 1'b0, pcPP4, AluOp_OR     };

    localparam DP_SB    = {asREG, bsIMM, wrALU, 1'b0, 1'b1, pcPP4, AluOp_ADD    };
    localparam DP_SH    = {asREG, bsIMM, wrALU, 1'b0, 1'b1, pcPP4, AluOp_ADD    };
    localparam DP_SLL   = {asREG, bsREG, wrALU, 1'b1, 1'b0, pcPP4, AluOp_SLL    };
    localparam DP_SLT   = {asREG, bsREG, wrALU, 1'b1, 1'b0, pcPP4, AluOp_SLT    };
    localparam DP_SLTI  = {asREG, bsIMM, wrALU, 1'b1, 1'b0, pcPP4, AluOp_SLT    };
    localparam DP_SLTIU = {asREG, bsIMM, wrALU, 1'b1, 1'b0, pcPP4, AluOp_SLTU   };
    localparam DP_SLTU  = {asREG, bsREG, wrALU, 1'b1, 1'b0, pcPP4, AluOp_SLTU   };
    localparam DP_SUB   = {asREG, bsREG, wrALU, 1'b1, 1'b0, pcPP4, AluOp_SUB    };
    localparam DP_SW    = {asREG, bsIMM, wrALU, 1'b0, 1'b1, pcPP4, AluOp_ADD    };

    localparam DP_XOR   = {asREG, bsREG, wrALU, 1'b1, 1'b0, pcPP4, AluOp_XOR    };
    localparam DP_XORI  = {asREG, bsIMM, wrALU, 1'b1, 1'b0, pcPP4, AluOp_AND    };


    logic [14:0] dp;
    logic br;


    // Evalua les senyals de control de sortida
    //
    assign o_aluControl   = AluOp'(dp[4:0]);
    assign o_memWrEnable  = dp[7];
    assign o_regWrEnable  = dp[8];
    assign o_regWrDataSel = dp[10:9];
    assign o_operandBSel  = dp[12:11];
    assign o_operandASel  = dp[14:13];
    assign o_pcNextSel    = br ? dp[6:5] : pcPP4;

    // Evalua les condicions de salt per les instruccions Branch y Jump
    //
    always_comb begin
        unique casez ({i_inst[14:12], i_inst[6:0], i_isEQ, i_isLT})
            /*  BEQ   */ 12'b000_1100011_1_?: br = 1;
            /*  BGE   */ 12'b101_1100011_?_0: br = 1;
            /*  BGEU  */ 12'b111_1100011_?_0: br = 1;
            /*  BLT   */ 12'b100_1100011_?_1: br = 1;
            /*  BLTU  */ 12'b110_1100011_?_1: br = 1;
            /*  BNE   */ 12'b001_1100011_0_?: br = 1;
            /*  JAL   */ 12'b???_1101111_?_?: br = 1;
            /*  JALR  */ 12'b000_1100111_?_?: br = 1;
            default                         : br = 0;
        endcase
    end

    // Evalua el datapath corresponent a cada instruccio
    //
    always_comb begin
        unique casez ({i_inst[31:25], i_inst[14:12], i_inst[6:0]})
            /*  ADD   */ {10'b0000000_000, OpCode_Op    }: dp = DP_ADD;
            /*  ADDI  */ {10'b???????_000, OpCode_OpIMM }: dp = DP_ADDI;
            /*  AND   */ {10'b0000000_111, OpCode_Op    }: dp = DP_AND;
            /*  ANDI  */ {10'b???????_111, OpCode_OpIMM }: dp = DP_ANDI;
            /*  AUIPC */ {10'b???????_???, OpCode_AUIPC }: dp = DP_AUIPC;

            /*  BEQ   */ {10'b???????_000, OpCode_Branch}: dp = DP_BEQ;
            /*  BGE   */ {10'b???????_101, OpCode_Branch}: dp = DP_BGE;
            /*  BGEU  */ {10'b???????_111, OpCode_Branch}: dp = DP_BGEU;
            /*  BLT   */ {10'b???????_100, OpCode_Branch}: dp = DP_BLT;
            /*  BLTU  */ {10'b???????_110, OpCode_Branch}: dp = DP_BLTU;
            /*  BNE   */ {10'b???????_001, OpCode_Branch}: dp = DP_BNE;

            /*  JAL   */ {10'b???????_???, OpCode_JAL   }: dp = DP_JAL;
            /*  JALR  */ {10'b???????_000, OpCode_JALR  }: dp = DP_JALR;

            /*  LUI   */ {10'b???????_???, OpCode_LUI   }: dp = DP_LUI;
            /*  LB    */ {10'b???????_000, OpCode_Load  }: dp = DP_LB;
            /*  LBU   */
            /*  LH    */ {10'b???????_001, OpCode_Load  }: dp = DP_LH;
            /*  LHU   */
            /*  LW    */ {10'b???????_010, OpCode_Load  }: dp = DP_LW;

            /*  OR    */ {10'b0000000_110, OpCode_Op    }: dp = DP_OR;
            /*  ORI   */ {10'b???????_110, OpCode_OpIMM }: dp = DP_ORI;

            /*  SB    */ {10'b???????_000, OpCode_Store }: dp = DP_SB;
            /*  SH    */ {10'b???????_001, OpCode_Store }: dp = DP_SH;
            /*  SLL   */ {10'b0000000_001, OpCode_Op    }: dp = DP_SLL;
            /*  SLLI  */
            /*  SLT   */ {10'b0000000_010, OpCode_Op    }: dp = DP_SLT;
            /*  SLTI  */ {10'b???????_010, OpCode_OpIMM }: dp = DP_SLTI;
            /*  SLTIU */ {10'b???????_011, OpCode_OpIMM }: dp = DP_SLTIU;
            /*  SLTU  */ {10'b0000000_011, OpCode_Op    }: dp = DP_SLTU;
            /*  SRA   */
            /*  SRAI  */
            /*  SRL   */
            /*  SRLI  */
            /*  SUB   */ {10'b0100000_000, OpCode_Op    }: dp = DP_SUB;
            /*  SW    */ {10'b???????_010, OpCode_Store }: dp = DP_SW;

            /*  XOR   */ {10'b0000000_100, OpCode_Op    }: dp = DP_XOR;
            /*  XORI  */ {10'b???????_100, OpCode_OpIMM }: dp = DP_XORI;

            default: dp = 0;
        endcase
    end

endmodule
