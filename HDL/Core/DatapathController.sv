module DatapathController
    import Types::*;
(
    input  Inst        i_inst,          // La instruccio
    input  logic       i_isEqual,       // Indica A == B
    input  logic       i_isLess,        // Indica A < B

    output logic       o_memWrEnable,   // Habilita l'escriptura en memoria
    output logic       o_memRdEnable,   // Habilita la lectura de la memoria
    output DataAccess  o_memAccess,     // Tamany d'acces a la memoria
    output logic       o_memUnsigned,   // Lectura de memoria sense signe

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
    localparam  pcIND = 2'b11;           // PC = [RS1] + offset

    always_comb begin

        o_aluControl   = AluOp_Unknown;
        o_operandASel  = asREG;
        o_operandBSel  = bsREG;
        o_pcNextSel    = pcPP4;
        o_memWrEnable  = 1'b0;
        o_memRdEnable  = 1'b0;
        o_memAccess    = DataAccess_Word;
        o_memUnsigned  = 1'b0;
        o_regWrEnable  = 1'b0;
        o_regWrDataSel = wrALU;

        unique casez ({i_inst[31:25], i_inst[14:12], i_inst[6:0]})
            {10'b???????_???, OpCode_LUI   }: // LUI
                begin
                    o_aluControl  = AluOp_ADD;
                    o_operandASel = asV0;
                    o_operandBSel = bsIMM;
                    o_regWrEnable = 1'b1;
                end

            {10'b???????_???, OpCode_AUIPC }: // AUIPC
                begin
                    o_aluControl  = AluOp_ADD;
                    o_operandASel = asPC;
                    o_operandBSel = bsIMM;
                    o_regWrEnable = 1'b1;
                end

            {10'b???????_???, OpCode_JAL   }: // JAL
                begin
                    o_regWrDataSel = wrPC4;
                    o_regWrEnable  = 1'b1;
                    o_pcNextSel    = pcOFS;
                end

            {10'b???????_000, OpCode_JALR  }: // JALR
                begin
                    o_regWrDataSel = wrPC4;
                    o_regWrEnable = 1'b1;
                    o_pcNextSel   = pcIND;
                end

            {10'b???????_000, OpCode_Branch}: // BEQ
                if (i_isEqual)
                    o_pcNextSel = pcOFS;

            {10'b???????_001, OpCode_Branch}: // BNE
                if (!i_isEqual)
                    o_pcNextSel = pcOFS;

            {10'b???????_110, OpCode_Branch}, // BLTU
            {10'b???????_100, OpCode_Branch}: // BLT
                if (i_isLess)
                    o_pcNextSel = pcOFS;

            {10'b???????_111, OpCode_Branch}, // BGEU
            {10'b???????_101, OpCode_Branch}: // BGE
                if (!i_isLess & !i_isEqual)
                    o_pcNextSel = pcOFS;

            {10'b???????_000, OpCode_Load  }, // LB
            {10'b???????_001, OpCode_Load  }, // LH
            {10'b???????_010, OpCode_Load  }, // LW
            {10'b???????_100, OpCode_Load  }, // LBU
            {10'b???????_101, OpCode_Load  }: // LHU
                begin
                    o_aluControl    = AluOp_ADD;
                    o_operandBSel   = bsIMM;
                    o_regWrDataSel  = wrMEM;
                    o_regWrEnable   = 1'b1;
                    o_memRdEnable   = 1'b1;
                    o_memUnsigned   = i_inst[14];

                    unique case (i_inst[13:12])
                        2'b00: o_memAccess = DataAccess_Byte;
                        2'b01: o_memAccess = DataAccess_Half;
                        default: ;
                    endcase
                end

            {10'b???????_000, OpCode_Store }, // SB
            {10'b???????_001, OpCode_Store }, // SH
            {10'b???????_010, OpCode_Store }: // SW
                begin
                    o_aluControl  = AluOp_ADD;
                    o_operandBSel = bsIMM;
                    o_memWrEnable = 1'b1;

                    unique case (i_inst[13:12])
                        2'b00: o_memAccess = DataAccess_Byte;
                        2'b01: o_memAccess = DataAccess_Half;
                        default: ;
                    endcase
                end

            {10'b???????_000, OpCode_OpIMM }, // ADDI
            {10'b???????_010, OpCode_OpIMM }, // SLTI
            {10'b???????_011, OpCode_OpIMM }, // SLTIU
            {10'b???????_100, OpCode_OpIMM }, // XORI
            {10'b???????_110, OpCode_OpIMM }, // ORI
            {10'b???????_111, OpCode_OpIMM }: // ANDI
                begin
                    o_operandBSel = bsIMM;
                    o_regWrEnable = 1'b1;

                    unique case (i_inst[14:12])
                        3'b000: o_aluControl = AluOp_ADD;
                        3'b010: o_aluControl = AluOp_SLT;
                        3'b011: o_aluControl = AluOp_SLTU;
                        3'b100: o_aluControl = AluOp_XOR;
                        3'b110: o_aluControl = AluOp_OR;
                        3'b111: o_aluControl = AluOp_AND;
                        default: ;
                    endcase
                end

            {10'b0000000_000, OpCode_Op    }, // ADD
            {10'b0100000_000, OpCode_Op    }, // SUB
            {10'b0000000_001, OpCode_Op    }, // SLL
            {10'b0000000_010, OpCode_Op    }, // SLT
            {10'b0000000_011, OpCode_Op    }, // SLTU
            {10'b0000000_100, OpCode_Op    }, // XOR
            {10'b0000000_101, OpCode_Op    }, // SRL
            {10'b0100000_101, OpCode_Op    }, // SRA
            {10'b0000000_110, OpCode_Op    }, // OR
            {10'b0000000_111, OpCode_Op    }: // AND
                begin
                    o_regWrEnable = 1'b1;

                    unique casez ({i_inst[30], i_inst[14:12]})
                        4'b0_000: o_aluControl = AluOp_ADD;
                        4'b1_000: o_aluControl = AluOp_SUB;
                        4'b?_001: o_aluControl = AluOp_SLL;
                        4'b?_010: o_aluControl = AluOp_SLT;
                        4'b?_011: o_aluControl = AluOp_SLTU;
                        4'b?_100: o_aluControl = AluOp_XOR;
                        4'b0_101: o_aluControl = AluOp_SRL;
                        4'b1_101: o_aluControl = AluOp_SRA;
                        4'b?_110: o_aluControl = AluOp_OR;
                        4'b?_111: o_aluControl = AluOp_AND;
                        default: ;
                    endcase
                end

            default: ;

        endcase
    end


endmodule
