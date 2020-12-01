package Types; 
    
    typedef enum logic [6:0] {
        OpCode_Load   = 7'h03,
        OpCode_OpIMM  = 7'h13,
        OpCode_AUIPC  = 7'h17,
        OpCode_Store  = 7'h23,
        OpCode_Op     = 7'h33,
        OpCode_LUI    = 7'h37,
        OpCode_Branch = 7'h63,
        OpCode_JALR   = 7'h67,
        OpCode_JAL    = 7'h6f
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