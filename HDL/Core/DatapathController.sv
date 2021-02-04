module DatapathController
    import Config::*, Types::*;
(
    input  Inst        i_inst,           // La instruccio

    input  logic       i_isEqual,        // Indica A == B
    input  logic       i_isLessSigned,   // Indica A < B amb signe
    input  logic       i_isLessUnsigned, // Indica A < B sense signe

    output logic       o_memWrEnable,    // Habilita l'escriptura en memoria
    output logic       o_memRdEnable,    // Habilita la lectura de la memoria
    output DataAccess  o_memAccess,      // Tamany d'acces a la memoria
    output logic       o_memUnsigned,    // Lectura de memoria sense signe

    output logic [1:0] o_pcNextSel,      // Selecciona el seguent valor del PC

    output AluOp       o_aluControl,     // Selecciona l'operacio en la unitat ALU
    output CsrOp       o_csrControl,     // Selecciona l'operacio en la unitat CSR
    output MduOp       o_mduControl,     // Selecciona l'operacio de la unitat MDU
    output DataASel    o_operandASel,    // Selecciona l'operand A
    output DataBSel    o_operandBSel,    // Selecciona l'operand B
    output ResultSel   o_resultSel,      // Selecciona el resultat

    output logic       o_regWrEnable,    // Habilita l'escriptura en els registres
    output WrDataSel   o_regWrDataSel);  // Selecciona les dades per escriure en el registre


    localparam  pcPP4 = 2'b00;  // PC = PC + 4
    localparam  pcOFS = 2'b01;  // PC = PC + offset
    localparam  pcIND = 2'b11;  // PC = [RS1] + offset


    always_comb begin

        o_aluControl   = AluOp_ADD;
        o_csrControl   = CsrOp_NOP;
        o_mduControl   = MduOp_MUL;
        o_operandASel  = DataASel_REG;
        o_operandBSel  = DataBSel_REG;
        o_resultSel    = ResultSel_ALU;
        o_pcNextSel    = pcPP4;
        o_memWrEnable  = 1'b0;
        o_memRdEnable  = 1'b0;
        o_memAccess    = DataAccess_Word;
        o_memUnsigned  = 1'b0;
        o_regWrEnable  = 1'b0;
        o_regWrDataSel = WrDataSel_CALC;

        unique casez ({i_inst[31:25], i_inst[14:12], i_inst[6:0]})
            {10'b???????_???, OpCode_LUI   }: // LUI
                begin
                    o_operandASel = DataASel_V0;
                    o_operandBSel = DataBSel_IMM;
                    o_regWrEnable = 1'b1;
                end

            {10'b???????_???, OpCode_AUIPC }: // AUIPC
                begin
                    o_operandASel = DataASel_PC;
                    o_operandBSel = DataBSel_IMM;
                    o_regWrEnable = 1'b1;
                end

            {10'b???????_???, OpCode_JAL   }: // JAL
                begin
                    o_operandASel = DataASel_PC;
                    o_operandBSel = DataBSel_V4;
                    o_regWrEnable = 1'b1;
                    o_pcNextSel   = pcOFS;
                end

            {10'b???????_000, OpCode_JALR  }: // JALR
                begin
                    o_operandASel = DataASel_PC;
                    o_operandBSel = DataBSel_V4;
                    o_regWrEnable = 1'b1;
                    o_pcNextSel   = pcIND;
                end

            {10'b???????_000, OpCode_Branch}: // BEQ
                if (i_isEqual)
                    o_pcNextSel = pcOFS;

            {10'b???????_001, OpCode_Branch}: // BNE
                if (!i_isEqual)
                    o_pcNextSel = pcOFS;

            {10'b???????_110, OpCode_Branch}: // BLTU
                if (i_isLessUnsigned)
                    o_pcNextSel = pcOFS;

            {10'b???????_100, OpCode_Branch}: // BLT
                if (i_isLessSigned)
                    o_pcNextSel = pcOFS;

            {10'b???????_111, OpCode_Branch}: // BGEU
                if (!i_isLessUnsigned | i_isEqual)
                    o_pcNextSel = pcOFS;

            {10'b???????_101, OpCode_Branch}: // BGE
                if (!i_isLessSigned | i_isEqual)
                    o_pcNextSel = pcOFS;

            {10'b???????_000, OpCode_Load  }, // LB
            {10'b???????_001, OpCode_Load  }, // LH
            {10'b???????_010, OpCode_Load  }, // LW
            {10'b???????_100, OpCode_Load  }, // LBU
            {10'b???????_101, OpCode_Load  }: // LHU
                begin
                    o_operandBSel  = DataBSel_IMM;
                    o_regWrDataSel = WrDataSel_LOAD;
                    o_regWrEnable  = 1'b1;
                    o_memRdEnable  = 1'b1;
                    o_memUnsigned  = i_inst[14];
                    o_memAccess    = DataAccess'(i_inst[13:12]);
                end

            {10'b???????_000, OpCode_Store }, // SB
            {10'b???????_001, OpCode_Store }, // SH
            {10'b???????_010, OpCode_Store }: // SW
                begin
                    o_operandBSel = DataBSel_IMM;
                    o_memWrEnable = 1'b1;
                    o_memAccess   = DataAccess'(i_inst[13:12]);
                end

            {10'b???????_000, OpCode_OpIMM }, // ADDI
            {10'b???????_010, OpCode_OpIMM }, // SLTI
            {10'b???????_011, OpCode_OpIMM }, // SLTIU
            {10'b???????_100, OpCode_OpIMM }, // XORI
            {10'b???????_110, OpCode_OpIMM }, // ORI
            {10'b???????_111, OpCode_OpIMM }: // ANDI
                begin
                    o_operandBSel = DataBSel_IMM;
                    o_regWrEnable = 1'b1;
                    o_aluControl  = AluOp'({1'b0, i_inst[14:12]});
                end

            {10'b0000001_000, OpCode_Op   }, // MUL
            {10'b0000001_001, OpCode_Op   }, // MULH
            {10'b0000001_010, OpCode_Op   }, // MULHSU
            {10'b0000001_011, OpCode_Op   }, // MULHU
            {10'b0000001_100, OpCode_Op   }, // DIV
            {10'b0000001_101, OpCode_Op   }, // DIVU
            {10'b0000001_110, OpCode_Op   }, // REM
            {10'b0000001_111, OpCode_Op   }: // REMU
                if (RV_EXT_M == 1) begin
                    o_regWrEnable = 1'b1;
                    o_mduControl = MduOp'(i_inst[14:12]);
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
                    o_aluControl  = AluOp'({i_inst[30], i_inst[14:12]});
                end

            {10'b???????_001, OpCode_System}, // CSRRW
            {10'b???????_010, OpCode_System}, // CRRRS
            {10'b???????_011, OpCode_System}: // CSRRC
                begin
                    o_regWrEnable = 1'b1;
                    o_resultSel   = ResultSel_CSR;
                    o_csrControl  = CsrOp'(i_inst[13:12]);
                end

            {10'b???????_101, OpCode_System}, // CSRRWI
            {10'b???????_110, OpCode_System}, // CSRRSI
            {10'b???????_111, OpCode_System}: // CSRRCI
                begin
                    o_operandASel = DataASel_IMM;
                    o_regWrEnable = 1'b1;
                    o_resultSel   = ResultSel_CSR;
                    o_csrControl = CsrOp'(i_inst[13:12]);
                end

            default:
                ;

        endcase
    end


endmodule
