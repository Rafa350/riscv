module DatapathController (

    input  logic [31:0] i_Inst,          // La instruccio
    input  logic        i_IsEQ,          // Indica A == B
    input  logic        i_IsLT,          // Indica A < B

    output logic        o_MemWrEnable,   // Habilita erscriptura en la memoria

    output logic [1:0]  o_PCNextSel,     // Selecciona el seguent valor del PC

    output Types::AluOp o_AluControl,    // Selecciona l'operacio en la ALU
    output logic [1:0]  o_OperandASel,
    output logic [1:0]  o_OperandBSel,   // Selecciona l'operand B de la ALU

    output logic        o_RegWrEnable,   // Habilita l'escriptura en els registres
    output logic [1:0]  o_RegWrDataSel); // Selecciona les dades per escriure en el registre


    import Types::*;

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
    assign o_AluControl   = AluOp'(dp[4:0]);
    assign o_MemWrEnable  = dp[7];
    assign o_RegWrEnable  = dp[8];
    assign o_RegWrDataSel = dp[10:9];
    assign o_OperandBSel  = dp[12:11];
    assign o_OperandASel  = dp[14:13];
    assign o_PCNextSel    = br ? dp[6:5] : pcPP4;

    // Evalua les condicions de salt per les instruccions Branch y Jump
    //
    always_comb begin
        unique casez ({i_Inst[14:12], i_Inst[6:0], i_IsEQ, i_IsLT})
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

    // Evalua el datapath coresponent a cada instruccio
    //
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
            /*  LBU   */
            /*  LH    */ 17'b???????_001_0000011: dp = DP_LH;
            /*  LHU   */
            /*  LW    */ 17'b???????_010_0000011: dp = DP_LW;

            /*  OR    */ 17'b0000000_110_0110011: dp = DP_OR;
            /*  ORI   */ 17'b???????_110_0010011: dp = DP_ORI;

            /*  SB    */ 17'b???????_000_0100011: dp = DP_SB;
            /*  SH    */ 17'b???????_001_0100011: dp = DP_SH;
            /*  SLL   */ 17'b0000000_001_0110011: dp = DP_SLL;
            /*  SLLI  */
            /*  SLT   */ 17'b0000000_010_0110011: dp = DP_SLT;
            /*  SLTI  */ 17'b???????_010_0010011: dp = DP_SLTI;
            /*  SLTIU */ 17'b???????_011_0010011: dp = DP_SLTIU;
            /*  SLTU  */ 17'b0000000_011_0110011: dp = DP_SLTU;
            /*  SRA   */
            /*  SRAI  */
            /*  SRL   */
            /*  SRLI  */
            /*  SUB   */ 17'b0100000_000_0110011: dp = DP_SUB;
            /*  SW    */ 17'b???????_010_0100011: dp = DP_SW;

            /*  XOR   */ 17'b0000000_100_0110011: dp = DP_XOR;
            /*  XORI  */ 17'b???????_100_0010011: dp = DP_XORI;

            default                             : dp = 0;
        endcase
    end

endmodule
