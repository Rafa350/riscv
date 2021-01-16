`include "RV.svh"

package Types;

    localparam DATA_WIDTH = `DATA_WIDTH;
    localparam ADDR_WIDTH = `ADDR_WIDTH;
    localparam PC_WIDTH   = `PC_WIDTH;
    localparam REG_WIDTH  = `REG_WIDTH;

    typedef logic [DATA_WIDTH-1:0] Data;       // Dades
    typedef logic [31:0]           Inst;       // Instruccions

    typedef logic [ADDR_WIDTH-1:0] DataAddr;   // Adressa de dades
    typedef logic [PC_WIDTH-1:0]   InstAddr;   // Adressa d'instruccio
    typedef logic [REG_WIDTH-1:0]  RegAddr;    // Adressa de registre int
    typedef logic [4:0]            FRegAddr;   // Adressa de registre float
    typedef logic [11:0]           CSRegAddr;  // Adressa de registre CSR

    typedef enum logic [1:0] {       // Modus d'acces a la memoria
        DataAccess_Byte  = 2'b00,    // -8 bits (BYTE)
        DataAccess_Half  = 2'b01,    // -16 bits (HALF WORD)
        DataAccess_Word  = 2'b10,    // -32 bits (WORD)
        DataAccess_DWord = 2'b11     // -64 bits (DOUBLE WORD)
    } DataAccess;

    typedef enum logic [6:0] {        // Codis d'operacio de les instruccions
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

    typedef enum logic[3:0] {  // Operacions ALU (Aritmetic/Logic Unit)
        AluOp_ADD  = 4'b0_000, // -ADD
        AluOp_AND  = 4'b0_111, // -AND
        AluOp_OR   = 4'b0_110, // -OR
        AluOp_SLL  = 4'b0_001, // -Logic shift right
        AluOp_SLT  = 4'b0_010, // -Set if less
        AluOp_SLTU = 4'b0_011, // -Set if less unsigned
        AluOp_SRA  = 4'b1_101, // -Arithmetic shift right
        AluOp_SRL  = 4'b0_101, // -Logic shift right
        AluOp_SUB  = 4'b1_000, // -SUB
        AluOp_XOR  = 4'b0_100  // -XOR
    } AluOp;

    typedef enum logic[2:0] {  // Operacions MDU (Multiply/Divide Unit)
        MduOp_MUL    = 3'b000, // -MUL
        MduOp_MULH   = 3'b001, // -MULH
        MduOp_MULHSU = 3'b010, // -MULHSU
        MduOp_MULHU  = 3'b011, // -MULHU
        MduOp_DIV    = 3'b100, // -DIV
        MduOp_DIVU   = 3'b101, // -DIVU
        MduOp_REM    = 3'b110, // -REM
        MduOp_REMU   = 3'b111  // -REMU
    } MduOp;


endpackage