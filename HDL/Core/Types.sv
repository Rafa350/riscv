`include "RV.svh"

package Types;

    localparam DATA_WIDTH = `DATA_WIDTH;
    localparam ADDR_WIDTH = `ADDR_WIDTH;
    localparam PC_WIDTH   = `PC_WIDTH;
    localparam REG_WIDTH  = `REG_WIDTH;

    typedef logic [DATA_WIDTH-1:0] Data;
    typedef logic [31:0]           Inst;

    typedef logic [ADDR_WIDTH-1:0] DataAddr;   // Adressa de dades
    typedef logic [PC_WIDTH-1:0]   InstAddr;   // Adressa d'instruccio
    typedef logic [REG_WIDTH-1:0]  RegAddr;    // Adressa de registre int
    typedef logic [4:0]            FRegAddr;   // Adressa de registre float
    typedef logic [11:0]           CSRegAddr;  // Adressa de registre CSR

    typedef enum logic [2:0] {
        DataAccess_Byte,
        DataAccess_Half,
        DataAccess_Word,
        DataAccess_DWord,
        DataAccess_QWord
    } DataAccess;

    typedef enum logic [6:0] {
        OpCode_Unknown = 7'b000_0000,
        OpCode_Fence   = 7'b000_1111,
        OpCode_Load    = 7'b000_0011,
        OpCode_Store   = 7'b010_0011,
        OpCode_Op      = 7'b011_0011,
        OpCode_OpIMM   = 7'b001_0011,
        OpCode_Branch  = 7'b110_0011,
        OpCode_System  = 7'b111_0011,
        OpCode_AUIPC   = 7'b001_0111,
        OpCode_JALR    = 7'b110_0111,
        OpCode_JAL     = 7'b110_1111,
        OpCode_LUI     = 7'b011_0111
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


endpackage