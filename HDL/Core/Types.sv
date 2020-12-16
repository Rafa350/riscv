`include "RV.svh"

package Types;

    localparam DATA_WIDTH = 32;
    localparam INST_WIDTH = 32;

    typedef logic [DATA_WIDTH-1:0] Data;
    typedef logic [INST_WIDTH-1:0] Inst;

    typedef logic [31:0] DataAddr;
    typedef logic [31:0] InstAddr;
    typedef logic [4:0]  RegAddr;

    typedef enum logic [6:0] {
        OpCode_Load   = 7'b000_0011,
        OpCode_Store  = 7'b010_0011,
        OpCode_Op     = 7'b011_0011,
        OpCode_OpIMM  = 7'b001_0011,
        OpCode_Branch = 7'b110_0011,
        OpCode_System = 7'b111_0011,
        OpCode_AUIPC  = 7'b001_0111,
        OpCode_JALR   = 7'b110_0111,
        OpCode_JAL    = 7'b110_1111,
        OpCode_LUI    = 7'b011_0111
    } OpCode;

    typedef enum logic[4:0] {
        AluOp_Unknown = 5'h00,
        AluOp_ADD,
        AluOp_ADDU,
        AluOp_AND,
        AluOp_DIV,
        AluOp_DIVU,
        AluOp_NOR,
        AluOp_OR,
        AluOp_SLL,
        AluOp_SLLV,
        AluOp_SLT,
        AluOp_SLTU,
        AluOp_SRA,
        AluOp_SRAV,
        AluOp_SRL,
        AluOP_SRLV,
        AluOp_SUB,
        AluOp_SUBU,
        AluOp_XOR
    } AluOp;

    typedef struct packed {
        logic [6:0] Func7;
        RegAddr RS2;
        RegAddr RS1;
        logic [2:0] Func3;
        RegAddr RD;
        OpCode Op;
    } InstRFormat;

    typedef struct packed {
        logic [11:0] Imm;
        RegAddr RS1;
        logic [2:0] Func3;
        RegAddr RD;
        OpCode Op;
    } InstIFormat;

    typedef struct packed {
        logic [6:0] Imm7;
        RegAddr RS2;
        RegAddr RS1;
        logic [2:0] Func3;
        logic [4:0] Imm5;
        OpCode Op;
    } InstSFormat;

    typedef struct packed {
        logic [19:0] Imm20;
        RegAddr RD;
        OpCode Op;
    } InstUFormat;

    typedef enum logic [11:0] {
        CSRAddr_USTATUS  = 12'h000,
        CSRAddr_UIE      = 12'h004,
        CSRAddr_UTVEC    = 12'h005,

        CSRAddr_USCRATCH = 12'h040,
        CSRAddr_UEPC     = 12'h041,
        CSRAddr_UCAUSE   = 12'h042,
        CSRAddr_UTVAL    = 12'h043,
        CSRAddr_UIP      = 12'h044,

        CSRAddr_FFLAGS   = 12'h001,
        CSRAddr_FRM      = 12'h002,
        CSRAddr_FCSR     = 12'h003,

        CSRAddr_CYCLE    = 12'hC00,
        CSRAddr_TIME     = 12'hC01,
        CSRAddr_INSTRET  = 12'hC02,

        CSRAddr_CYCLEH   = 12'hC80,
        CSRAddr_TIMEH    = 12'hC81,
        CSRAddr_INSTRETH = 12'hC82
    } CSRAddr;

endpackage