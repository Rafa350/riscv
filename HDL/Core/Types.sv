package Types; 

    localparam DATA_WIDTH = 32;
    localparam INST_WIDTH = 32;

    typedef logic [DATA_WIDTH-1:0] Data;
    typedef logic [INST_WIDTH-1:0] Inst;

    typedef logic [31:0] DataAddr;
    typedef logic [31:0] InstAddr;
    typedef logic [4:0]  RegAddr;
    
    typedef enum logic [6:0] {
        OpCode_Load   = 7'h03,
        OpCode_Store  = 7'h23,
        OpCode_Op     = 7'h33,
        OpCode_OpIMM  = 7'h13,
        OpCode_Branch = 7'h63,
        OpCode_System = 7'h73,
        OpCode_AUIPC  = 7'h17,
        OpCode_JALR   = 7'h67,
        OpCode_JAL    = 7'h6F,
        OpCode_LUI    = 7'h37
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