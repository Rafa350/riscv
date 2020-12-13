module InstDecoder
    import Types::*;
#(
    parameter DATA_WIDTH = 32,
    parameter REG_WIDTH  = 5)
 (
    input  logic [31:0]           i_Inst,      // La instruccio a decodificar
    output Types::OpCode          o_OP,        // El codi d'operacio
    output logic [REG_WIDTH-1:0]  o_RS1,       // El registre font 1 (rs1)
    output logic [REG_WIDTH-1:0]  o_RS2,       // El registre fomt 2 (rs2)
    output logic [REG_WIDTH-1:0]  o_RD,        // El registre de destinacio (rd)
    output logic [DATA_WIDTH-1:0] o_IMM,       // El valor inmediat
    output logic                  o_IsIllegal, // Indica instruccio ilegal
    output logic                  o_IsLoad,    // Indica que es una instruccio LOAD
    output logic                  o_IsALU,     // Indica que es una instruccio ALU
    output logic                  o_IsECALL,   // Indica instruccio ECALL
    output logic                  o_IsEBREAK); // Indica instruccio EBREAK


    logic [DATA_WIDTH-1:0] ImmIValue,
                           ImmSValue,
                           ImmBValue,
                           ImmUValue,
                           ImmJValue,
                           ShamtValue;

    assign ImmIValue  = {{20{i_Inst[31]}}, i_Inst[31:20]};
    assign ImmSValue  = {{20{i_Inst[31]}}, i_Inst[31:25], i_Inst[11:7]};
    assign ImmBValue  = {{20{i_Inst[31]}}, i_Inst[7], i_Inst[30:25], i_Inst[11:8], 1'b0};
    assign ImmJValue  = {{12{i_Inst[31]}}, i_Inst[19:12], i_Inst[20], i_Inst[30:21], 1'b0};
    assign ImmUValue  = {i_Inst[31:12], 12'b0};
    assign ShamtValue = {{27{1'b0}}, i_Inst[24:20]};

    always_comb begin

        o_OP  = Types::OpCode'(i_Inst[6:0]);
        o_RS1 = i_Inst[REG_WIDTH+14:15];
        o_RS2 = i_Inst[REG_WIDTH+19:20];
        o_RD  = i_Inst[REG_WIDTH+6:7];
        o_IMM = 0;

        o_IsIllegal = 1'b0;
        o_IsALU     = 1'b0;
        o_IsLoad    = 1'b0;
        o_IsEBREAK  = 1'b0;
        o_IsECALL   = 1'b0;

        unique casez ({i_Inst[31:25], i_Inst[14:12], i_Inst[6:0]})
            {10'b???????_???, OpCode_LUI   }, // LUI
            {10'b???????_???, OpCode_AUIPC }: // AUIPC
                o_IMM = ImmUValue;

            {10'b???????_???, OpCode_JAL   }: // JAL
                o_IMM = ImmJValue;

            {10'b???????_000, OpCode_JALR  }: // JALR
                o_IMM = ImmIValue;

            {10'b???????_000, OpCode_Branch}, // BEQ
            {10'b???????_001, OpCode_Branch}, // BNE
            {10'b???????_100, OpCode_Branch}, // BLT
            {10'b???????_101, OpCode_Branch}, // BGE
            {10'b???????_110, OpCode_Branch}, // BLTU
            {10'b???????_111, OpCode_Branch}: // BGEU
                o_IMM = ImmBValue;

            {10'b0000000_001, OpCode_OpIMM }, // SLLI
            {10'b0000000_101, OpCode_OpIMM }, // SRLI
            {10'b0100000_101, OpCode_OpIMM }: // SRAI
                begin
                    o_IMM = ShamtValue;
                    o_IsALU = 1'b1;
                end

            {10'b???????_000, OpCode_Load  }, // LB
            {10'b???????_001, OpCode_Load  }, // LH
            {10'b???????_010, OpCode_Load  }, // LW
            {10'b???????_100, OpCode_Load  }, // LBU
            {10'b???????_101, OpCode_Load  }: // LHU
                begin
                    o_IMM = ImmIValue;
                    o_IsLoad = 1'b1;
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
                o_IsALU = 1'b1;

            {10'b???????_000, OpCode_OpIMM }, // ADDI
            {10'b???????_010, OpCode_OpIMM }, // SLTI
            {10'b???????_011, OpCode_OpIMM }, // SLTIU
            {10'b???????_100, OpCode_OpIMM }, // XORI
            {10'b???????_110, OpCode_OpIMM }, // ORI
            {10'b???????_111, OpCode_OpIMM }: // ANDI
                begin
                    o_IMM = ImmIValue;
                    o_IsALU = 1'b1;
                end

            {10'b???????_000, OpCode_Store }, // SB
            {10'b???????_001, OpCode_Store }, // SH
            {10'b???????_010, OpCode_Store }: // SW
                o_IMM = ImmSValue;

            {10'b0000000_000, OpCode_System}:
                case (i_Inst[24:20])
                    5'b0000:                  // EBREAK
                        o_IsEBREAK = 1'b1;

                    5'b0001:                  // ECALL
                        o_IsECALL = 1'b1;

                    default:
                        o_IsIllegal = 1'b1;
                endcase

            default:
                o_IsIllegal = 1'b1;
        endcase

    end

endmodule
