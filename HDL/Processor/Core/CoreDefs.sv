package CoreDefs;

    import Config::*;

    typedef logic [DATA_WIDTH-1:0] Data;      // Dades
    typedef logic [31:0]           Inst;      // Instruccions

    typedef logic [ADDR_WIDTH-1:0] DataAddr;  // Adressa de dades en bytes
    typedef logic [PC_WIDTH-1:0]   InstAddr;  // Adressa d'instruccio en bytes
    typedef logic [REG_WIDTH-1:0]  GPRAddr;   // Adressa de registre GPR (General Purpouse Register)
    typedef logic [4:0]            FPRAddr;   // Adressa de registre FPR (Floating Point >Register)
    typedef logic [11:0]           CSRAddr;   // Adressa de registre CSR (Control & Status Register)

    typedef logic [(DATA_WIDTH/8)-1:0] ByteMask; // Mascara de bytes per access a memoria

    typedef enum logic [1:0] {       // Modus d'acces a la memoria
        DataAccess_Byte  = 2'b00,    // -8 bits (BYTE)
        DataAccess_Half  = 2'b01,    // -16 bits (HALF WORD)
        DataAccess_Word  = 2'b10,    // -32 bits (WORD)
        DataAccess_DWord = 2'b11     // -64 bits (DOUBLE WORD)
    } DataAccess;

    typedef enum logic [1:0] {       // Modus d'execucio
        RunMode_User       = 2'b00,  // -Usuari
        RunMode_Supervisor = 2'b01,  // -Supervisor
        RunMode_Hipervisor = 2'b10,  // -Hipervisor
        RunMode_Machine    = 2'b11   // -Maquina
    } RunMode;

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

    typedef enum logic [1:0] { // Operacions amb el bloc CSR
        CsrOp_NOP   = 2'b00,   // -No operation
        CsrOp_WRITE = 2'b01,   // -Write
        CsrOp_SET   = 2'b10,   // -Set bits
        CsrOp_CLEAR = 2'b11    // -Clear bits
    } CsrOp;

    typedef enum logic [1:0] { // Seleccio de dades A
        DataASel_REG = 2'b00,  // -Valor del registre rs1
        DataASel_IMM = 2'b01,  // -Valor immediat
        DataASel_V0  = 2'b10,  // -Valor 0
        DataASel_PC  = 2'b11   // -Valor del PC
    } DataASel;

    typedef enum logic [1:0] { // Seleccio de dades B
        DataBSel_REG = 2'b00,  // -Valor del registre rs2
        DataBSel_IMM = 2'b01,  // -Valor immediat
        DataBSel_V4  = 2'b10   // -Valor 4
    } DataBSel;

    typedef enum logic [1:0] { // Seleccion del resultat
        ResultSel_ALU = 2'b00, // -Resultat de la operacio ALU
        ResultSel_CSR = 2'b01  // -Resultat de la sortida de CSR
    } ResultSel;

    typedef enum logic {       // Selecciona les dades per escriure en RD
        WrDataSel_CALC = 1'b0, // -Valor calculat
        WrDataSel_LOAD = 1'b1  // -Valor lleigit
    } WrDataSel;

endpackage