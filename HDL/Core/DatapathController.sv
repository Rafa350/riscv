module DatapathController
    import Types::*;
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

    output AluOp       o_aluControl,     // Selecciona l'operacio en la ALU
`ifdef RV_EXT_M
    output MduOp       o_mduControl,     // Selecciona l'operacio de la MDU
`endif
    output logic [1:0] o_operandASel,    // Selecciona l'operand A
    output logic [1:0] o_operandBSel,    // Selecciona l'operand B

    output logic       o_regWrEnable,    // Habilita l'escriptura en els registres
    output logic [1:0] o_regWrDataSel);  // Selecciona les dades per escriure en el registre


    localparam  asREG = 2'b00;  // Selecciona el valor del registre
    localparam  asPC  = 2'b01;  // Selecciona el valor del PC
    localparam  asV0  = 2'b10;  // Selecciona el valor 0

    localparam  bsREG = 2'b00;  // Selecciona el valor del registre
    localparam  bsIMM = 2'b01;  // Selecciona el valor IMM
    localparam  bsV4  = 2'b10;  // Selecciona el valor 4

    localparam  wrALU = 2'b00;  // Escriu el valor de la ALU
    localparam  wrMEM = 2'b01;  // Escriu el valor de la memoria
    localparam  wrPC4 = 2'b10;  // Escriu el valor de PC+4

    localparam  pcPP4 = 2'b00;  // PC = PC + 4
    localparam  pcOFS = 2'b01;  // PC = PC + offset
    localparam  pcIND = 2'b11;  // PC = [RS1] + offset


    always_comb begin

        o_aluControl   = AluOp_ADD;
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
                    o_aluControl   = AluOp_ADD;
                    o_operandBSel  = bsIMM;
                    o_regWrDataSel = wrMEM;
                    o_regWrEnable  = 1'b1;
                    o_memRdEnable  = 1'b1;
                    o_memUnsigned  = i_inst[14];
                    o_memAccess    = DataAccess'(i_inst[13:12]);
                end

            {10'b???????_000, OpCode_Store }, // SB
            {10'b???????_001, OpCode_Store }, // SH
            {10'b???????_010, OpCode_Store }: // SW
                begin
                    o_aluControl  = AluOp_ADD;
                    o_operandBSel = bsIMM;
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
                    o_operandBSel = bsIMM;
                    o_regWrEnable = 1'b1;
                    o_aluControl  = AluOp'({1'b0, i_inst[14:12]});
                end

`ifdef RV_EXT_M
            {10'b0000001_000, OpCode_Op   }, // MUL
            {10'b0000001_001, OpCode_Op   }, // MULH
            {10'b0000001_010, OpCode_Op   }, // MULHSU
            {10'b0000001_011, OpCode_Op   }, // MULHU
            {10'b0000001_100, OpCode_Op   }, // DIV
            {10'b0000001_101, OpCode_Op   }, // DIVU
            {10'b0000001_110, OpCode_Op   }, // REM
            {10'b0000001_111, OpCode_Op   }: // REMU
                begin
                end
`endif

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

            default: ;

        endcase
    end


endmodule
