module InstDecoder
    import Config::*, Types::*;
 (
    input  Inst      i_inst,      // La instruccio a decodificar
    output OpCode    o_instOP,    // El codi d'operacio
    output RegAddr   o_instRS1,   // El registre origen 1 (rs1)
    output RegAddr   o_instRS2,   // El registre origen 2 (rs2)
    output RegAddr   o_instRD,    // El registre desti (rd)
    output CSRegAddr o_instCSR,   // El registre CSR
    output Data      o_instIMM,   // El valor inmediat
    output logic     o_isIllegal, // Indica instruccio ilegal
    output logic     o_isALU,     // Indica que es una instruccio ALU
    output logic     o_isECALL,   // Indica instruccio ECALL
    output logic     o_isEBREAK,  // Indica instruccio EBREAK
    output logic     o_isMRET,    // Indica instruccio MRET
    output logic     o_isCSR);    // Indica que es una instruccio CSR


    Data immIValue,
         immSValue,
         immBValue,
         immUValue,
         immJValue,
         shamtValue;


    assign immIValue  = {{21{i_inst[31]}}, i_inst[30:20]};
    assign immSValue  = {{21{i_inst[31]}}, i_inst[30:25], i_inst[11:7]};
    assign immBValue  = {{20{i_inst[31]}}, i_inst[7], i_inst[30:25], i_inst[11:8], 1'b0};
    assign immJValue  = {{12{i_inst[31]}}, i_inst[19:12], i_inst[20], i_inst[30:21], 1'b0};
    assign immUValue  = {i_inst[31:12], 12'b0};
    assign shamtValue = {{27{1'b0}}, i_inst[24:20]};


    always_comb begin

        o_instOP    = OpCode'(i_inst[6:0]);
        o_instRS1   = i_inst[REG_WIDTH+14:15];
        o_instRS2   = i_inst[REG_WIDTH+19:20];
        o_instRD    = i_inst[REG_WIDTH+6:7];
        o_instIMM   = 0;
        o_instCSR   = i_inst[31:20];

        o_isIllegal = 1'b0;
        o_isALU     = 1'b0;
        o_isEBREAK  = 1'b0;
        o_isECALL   = 1'b0;
        o_isMRET    = 1'b0;
        o_isCSR     = 1'b0;

        unique casez ({i_inst[31:25], i_inst[14:12], i_inst[6:0]})
            {10'b???????_???, OpCode_LUI   }, // LUI
            {10'b???????_???, OpCode_AUIPC }: // AUIPC
                o_instIMM = immUValue;

            {10'b???????_???, OpCode_JAL   }: // JAL
                o_instIMM = immJValue;

            {10'b???????_000, OpCode_JALR  }: // JALR
                o_instIMM = immIValue;

            {10'b???????_000, OpCode_Branch}, // BEQ
            {10'b???????_001, OpCode_Branch}, // BNE
            {10'b???????_100, OpCode_Branch}, // BLT
            {10'b???????_101, OpCode_Branch}, // BGE
            {10'b???????_110, OpCode_Branch}, // BLTU
            {10'b???????_111, OpCode_Branch}: // BGEU
                o_instIMM = immBValue;

            {10'b0000000_001, OpCode_OpIMM }, // SLLI
            {10'b0000000_101, OpCode_OpIMM }, // SRLI
            {10'b0100000_101, OpCode_OpIMM }: // SRAI
                begin
                    o_instIMM = shamtValue;
                    o_isALU = 1'b1;
                end

            {10'b???????_000, OpCode_Load  }, // LB
            {10'b???????_001, OpCode_Load  }, // LH
            {10'b???????_010, OpCode_Load  }, // LW
            {10'b???????_100, OpCode_Load  }, // LBU
            {10'b???????_101, OpCode_Load  }: // LHU
                o_instIMM = immIValue;

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
                o_isALU = 1'b1;

            {10'b0000001_???, OpCode_Op    }: // MUL, MULH, MULHSU, MULHU, DIV, DIVU, REM, REMU
                if (RV_EXT_M == 1)
                    o_isALU = 1'b1;
                else
                    o_isIllegal = 1'b1;

            {10'b???????_000, OpCode_OpIMM }, // ADDI
            {10'b???????_010, OpCode_OpIMM }, // SLTI
            {10'b???????_011, OpCode_OpIMM }, // SLTIU
            {10'b???????_100, OpCode_OpIMM }, // XORI
            {10'b???????_110, OpCode_OpIMM }, // ORI
            {10'b???????_111, OpCode_OpIMM }: // ANDI
                begin
                    o_instIMM = immIValue;
                    o_isALU = 1'b1;
                end

            {10'b???????_000, OpCode_Store }, // SB
            {10'b???????_001, OpCode_Store }, // SH
            {10'b???????_010, OpCode_Store }: // SW
                o_instIMM = immSValue;

            {10'b0000???_000, OpCode_Fence }: // FENCE
                o_isIllegal = 1'b1;

            {10'b0000000_001, OpCode_Fence }: // FENCE.I
                o_isIllegal = 1'b1;

            {10'b0000000_000, OpCode_System}:
                case (i_inst[24:20])
                    5'b0000:                  // EBREAK
                        o_isEBREAK = 1'b1;

                    5'b0001:                  // ECALL
                        o_isECALL = 1'b1;

                    default:
                        o_isIllegal = 1'b1;
                endcase

            {10'b0011000_000, OpCode_System}:
                case (i_inst[24:20])
                    5'b0010:                  // MRET
                        o_isMRET = 1'b1;

                    default:
                        o_isIllegal = 1'b1;
                endcase

            {10'b???????_001, OpCode_System}, // CSRRW
            {10'b???????_010, OpCode_System}, // CRRRS
            {10'b???????_011, OpCode_System}: // CSRRC
                o_isCSR = 1'b1;

            {10'b???????_101, OpCode_System}, // CSRRWI
            {10'b???????_110, OpCode_System}, // CSRRSI
            {10'b???????_111, OpCode_System}: // CSRRCI
                o_isCSR = 1'b1;

            default:
                o_isIllegal = 1'b1;
        endcase

    end

endmodule
