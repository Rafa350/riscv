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

        // verilator lint_off CASEINCOMPLETE
        unique casez (i_inst[6:0])
            OpCode_LUI: // LUI
                begin
                    o_operandASel = DataASel_V0;
                    o_operandBSel = DataBSel_IMM;
                    o_regWrEnable = 1'b1;
                end

            OpCode_AUIPC: // AUIPC
                begin
                    o_operandASel = DataASel_PC;
                    o_operandBSel = DataBSel_IMM;
                    o_regWrEnable = 1'b1;
                end

            OpCode_JAL: // JAL
                begin
                    o_operandASel = DataASel_PC;
                    o_operandBSel = DataBSel_V4;
                    o_regWrEnable = 1'b1;
                    o_pcNextSel   = pcOFS;
                end

            OpCode_JALR: // JALR
                if (i_inst[14:12] == 3'b000) begin
                    o_operandASel = DataASel_PC;
                    o_operandBSel = DataBSel_V4;
                    o_regWrEnable = 1'b1;
                    o_pcNextSel   = pcIND;
                end

            OpCode_Branch:
                unique case (i_inst[14:12])
                    3'b000: // BEQ
                        if (i_isEqual)
                            o_pcNextSel = pcOFS;

                    3'b001: // BNE
                        if (!i_isEqual)
                            o_pcNextSel = pcOFS;

                    3'b110: // BLTU
                        if (i_isLessUnsigned)
                            o_pcNextSel = pcOFS;

                    3'b100: // BLT
                        if (i_isLessSigned)
                            o_pcNextSel = pcOFS;

                    3'b111: // BGEU
                        if (!i_isLessUnsigned | i_isEqual)
                            o_pcNextSel = pcOFS;

                    3'b101: // BGE
                        if (!i_isLessSigned | i_isEqual)
                            o_pcNextSel = pcOFS;
                endcase

            OpCode_Load:
                unique case (i_inst[14:12])
                    3'b000, // LB
                    3'b001, // LH
                    3'b010, // LW
                    3'b100, // LBU
                    3'b101: // LHU
                        begin
                            o_operandBSel  = DataBSel_IMM;
                            o_regWrDataSel = WrDataSel_LOAD;
                            o_regWrEnable  = 1'b1;
                            o_memRdEnable  = 1'b1;
                            o_memUnsigned  = i_inst[14];
                            o_memAccess    = DataAccess'(i_inst[13:12]);
                        end
                endcase

            OpCode_Store:
                unique case (i_inst[14:12])
                    3'b000, // SB
                    3'b001, // SH
                    3'b010: // SW
                        begin
                            o_operandBSel = DataBSel_IMM;
                            o_memWrEnable = 1'b1;
                            o_memAccess   = DataAccess'(i_inst[13:12]);
                        end
                endcase

            OpCode_OpIMM:
                unique case (i_inst[14:12])
                    3'b000, // ADDI
                    3'b001, // SLLI
                    3'b010, // SLTI
                    3'b011, // SLTIU
                    3'b100, // XORI
                    3'b101, // SRLI/SRAI
                    3'b110, // ORI
                    3'b111: // ANDI
                        begin
                            o_operandBSel = DataBSel_IMM;
                            o_regWrEnable = 1'b1;
                            o_aluControl  = AluOp'({i_inst[14:12] == 3'b101 ? i_inst[30] : 1'b0, i_inst[14:12]});
                        end
                endcase

            OpCode_Op:
                unique case ({i_inst[31:25], i_inst[14:12]})
                    10'b0000001_000, // MUL
                    10'b0000001_001, // MULH
                    10'b0000001_010, // MULHSU
                    10'b0000001_011, // MULHU
                    10'b0000001_100, // DIV
                    10'b0000001_101, // DIVU
                    10'b0000001_110, // REM
                    10'b0000001_111: // REMU
                        if (RV_EXT_M == 1) begin
                            o_regWrEnable = 1'b1;
                            o_mduControl = MduOp'(i_inst[14:12]);
                        end

                    10'b0000000_000, // ADD
                    10'b0100000_000, // SUB
                    10'b0000000_001, // SLL
                    10'b0000000_010, // SLT
                    10'b0000000_011, // SLTU
                    10'b0000000_100, // XOR
                    10'b0000000_101, // SRL
                    10'b0100000_101, // SRA
                    10'b0000000_110, // OR
                    10'b0000000_111: // AND
                        begin
                            o_regWrEnable = 1'b1;
                            o_aluControl  = AluOp'({i_inst[30], i_inst[14:12]});
                        end
                endcase

            OpCode_System:
                unique case (i_inst[14:12])
                    3'b001, // CSRRW
                    3'b010, // CRRRS
                    3'b011: // CSRRC
                        begin
                            o_regWrEnable = 1'b1;
                            o_resultSel   = ResultSel_CSR;
                            o_csrControl  = CsrOp'(i_inst[13:12]);
                        end

                    3'b101, // CSRRWI
                    3'b110, // CSRRSI
                    3'b111: // CSRRCI
                        begin
                            o_operandASel = DataASel_IMM;
                            o_regWrEnable = 1'b1;
                            o_resultSel   = ResultSel_CSR;
                            o_csrControl = CsrOp'(i_inst[13:12]);
                        end
                endcase
        endcase
        // verilator lint_on CASEINCOMPLETE
    end


endmodule
