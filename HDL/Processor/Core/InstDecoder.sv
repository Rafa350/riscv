module InstDecoder (
    input  ProcessorDefs::Inst    i_inst,      // La instruccio a decodificar
    output CoreDefs::OpCode       o_instOP,    // El codi d'operacio
    output ProcessorDefs::GPRAddr o_instRS1,   // El registre origen 1 (rs1)
    output ProcessorDefs::GPRAddr o_instRS2,   // El registre origen 2 (rs2)
    output ProcessorDefs::GPRAddr o_instRD,    // El registre desti (rd)
    output ProcessorDefs::CSRAddr o_instCSR,   // El registre CSR
    output ProcessorDefs::Data    o_instIMM,   // El valor IMM
    output logic                  o_isIllegal, // Indica instruccio ilegal
    output logic                  o_isALU,     // Indica que es una instruccio ALU
    output logic                  o_isECALL,   // Indica instruccio ECALL
    output logic                  o_isEBREAK,  // Indica instruccio EBREAK
    output logic                  o_isWFI,     // Indica isntruccio WFI
    output logic                  o_isMRET,    // Indica instruccio MRET
    output logic                  o_isCSR);    // Indica que es una instruccio CSR


    ProcessorDefs::Data immIValue;
    ProcessorDefs::Data immSValue;
    ProcessorDefs::Data immBValue;
    ProcessorDefs::Data immUValue;
    ProcessorDefs::Data immJValue;
    ProcessorDefs::Data shamtValue;
    ProcessorDefs::Data csrValue;


    assign immIValue  = {{21{i_inst[31]}}, i_inst[30:20]};
    assign immSValue  = {{21{i_inst[31]}}, i_inst[30:25], i_inst[11:7]};
    assign immBValue  = {{20{i_inst[31]}}, i_inst[7], i_inst[30:25], i_inst[11:8], 1'b0};
    assign immJValue  = {{12{i_inst[31]}}, i_inst[19:12], i_inst[20], i_inst[30:21], 1'b0};
    assign immUValue  = {i_inst[31:12], 12'b0};
    assign shamtValue = {{27{1'b0}}, i_inst[24:20]};
    assign csrValue   = {{27{1'b0}}, i_inst[19:15]};

    assign o_instOP   = CoreDefs::OpCode'(i_inst[6:0]);
    assign o_instRS1  = i_inst[Config::REG_WIDTH+14:15];
    assign o_instRS2  = i_inst[Config::REG_WIDTH+19:20];
    assign o_instRD   = i_inst[Config::REG_WIDTH+6:7];
    assign o_instCSR  = i_inst[31:20];

    always_comb begin

        o_instIMM   = 0;
        o_isIllegal = 1'b1;
        o_isALU     = 1'b0;
        o_isEBREAK  = 1'b0;
        o_isECALL   = 1'b0;
        o_isWFI     = 1'b0;
        o_isMRET    = 1'b0;
        o_isCSR     = 1'b0;

        // verilator lint_off CASEINCOMPLETE
        unique case (i_inst[6:0])

            CoreDefs::OpCode_LUI,   // LUI
            CoreDefs::OpCode_AUIPC: // AUIPC
                begin
                    o_instIMM = immUValue;
                    o_isIllegal = 1'b0;
                end

            CoreDefs::OpCode_JAL: // JAL
                begin
                    o_instIMM = immJValue;
                    o_isIllegal = 1'b0;
                end

            CoreDefs::OpCode_JALR: //JALR
                begin
                    o_instIMM = immIValue;
                    o_isIllegal = 1'b0;
                end

            CoreDefs::OpCode_Branch:
                unique case (i_inst[14:12])
                    3'b000, // BEQ
                    3'b001, // BNE
                    3'b100, // BLT
                    3'b101, // BGE
                    3'b110, // BLTU
                    3'b111: // BGEU
                        begin
                            o_instIMM = immBValue;
                            o_isIllegal = 1'b0;
                        end
                endcase

            CoreDefs::OpCode_Op:
                unique casez ({i_inst[31:25], i_inst[14:12]})
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
                            o_isALU = 1'b1;
                            o_isIllegal = 1'b0;
                        end

                    10'b0000001_???: // MUL, MULH, MULHSU, MULHU, DIV, DIVU, REM, REMU
                        if (Config::RV_EXT_M == 1) begin
                            o_isALU = 1'b1;
                            o_isIllegal = 1'b0;
                        end
                endcase

            CoreDefs::OpCode_OpIMM:
                unique case (i_inst[14:12])
                    3'b000, // ADDI
                    3'b010, // SLTI
                    3'b011, // SLTIU
                    3'b100, // XORI
                    3'b110, // ORI
                    3'b111: // ANDI
                        begin
                            o_instIMM = immIValue;
                            o_isALU = 1'b1;
                            o_isIllegal = 1'b0;
                        end

                    3'b001: // SLLI
                        if (i_inst[31:25] == 7'b0000000) begin
                            o_instIMM = shamtValue;
                            o_isALU = 1'b1;
                            o_isIllegal = 1'b0;
                        end

                    3'b101: // SRLI, SRAI
                        if ((i_inst[31:25] == 7'b0000000) |
                            (i_inst[31:25] == 7'b0100000)) begin
                            o_instIMM = shamtValue;
                            o_isALU = 1'b1;
                            o_isIllegal = 1'b0;
                        end
                endcase

            CoreDefs::OpCode_Load:
                unique case (i_inst[14:12])
                    3'b000, // LB
                    3'b001, // LH
                    3'b010, // LW
                    3'b100, // LBU
                    3'b101: // LHU
                        begin
                            o_instIMM = immIValue;
                            o_isIllegal = 1'b0;
                        end
                endcase

            CoreDefs::OpCode_Store:
                unique case (i_inst[14:12])
                    3'b000, // SB
                    3'b001, // SH
                    3'b010: // SW
                        begin
                            o_instIMM = immSValue;
                            o_isIllegal = 1'b0;
                        end
                endcase

            CoreDefs::OpCode_Fence:
                unique casez ({i_inst[31:25], i_inst[14:12]})
                    10'b0000???_000: // FENCE
                        ;

                    10'b0000000_001: // FENCE.I
                        if (Config::RV_EXT_Zifencei == 1) begin
                            o_isIllegal = 1'b0;
                        end
                endcase

            CoreDefs::OpCode_System:
                unique case (i_inst[14:12])
                    3'b000:
                        unique case (i_inst[31:25])
                            7'b0000000:
                                unique case ({i_inst[24:20], i_inst[19:15], i_inst[11:7]})
                                    15'b00000_00000_00000: // EBREAK
                                        begin
                                            o_isEBREAK = 1'b1;
                                            o_isIllegal = 1'b0;
                                        end

                                    15'b00001_00000_00000: // ECALL
                                        begin
                                            o_isECALL = 1'b1;
                                            o_isIllegal = 1'b0;
                                        end
                                endcase

                            7'b0001000:
                                unique case ({i_inst[24:20], i_inst[19:15], i_inst[11:7]})
                                    15'b00101_00000_00000: // WFI
                                        begin
                                            o_isWFI = 1'b1;
                                            o_isIllegal = 1'b0;
                                        end
                                endcase

                            7'b0011000:
                                unique case (i_inst[24:20])
                                    5'b00010: // MRET
                                        begin
                                            o_isMRET = 1'b1;
                                            o_isIllegal = 1'b0;
                                        end
                                endcase
                        endcase


                    3'b001, // CSRRW
                    3'b010, // CRRRS
                    3'b011: // CSRRC
                        if (Config::RV_EXT_Zicsr == 1) begin
                            o_isCSR = 1'b1;
                            o_isIllegal = 1'b0;
                        end

                    3'b101, // CSRRWI
                    3'b110, // CSRRSI
                    3'b111: // CSRRCI
                        if (Config::RV_EXT_Zicsr == 1) begin
                            o_instIMM = csrValue;
                            o_isCSR = 1'b1;
                            o_isIllegal = 1'b0;
                        end
                endcase
        endcase
        // verilator lint_on CASEINCOMPLETE

    end

endmodule
