package types;

    // ISA Opcodes
    //
    typedef enum logic[5:0] {
        InstOp_RType = 6'b000000,
        InstOp_ADDI  = 6'b001001,
        InstOp_ADDIU = 6'b001000,
        InstOp_ANDI  = 6'b001100,
        InstOp_J     = 6'b000010,
        InstOp_JAL   = 6'b000011,
        InstOp_LW    = 6'b100011,
        InstOp_SW    = 6'b101011
    } InstOp;
    
    // R-Type function codes
    //
    typedef enum logic[5:0] {
        InstFn_ADD   = 6'b100000,
        InstFn_ADDU  = 6'b100001,
        InstFn_AND   = 6'b100100,
        InstFn_break = 6'b001101,
        InstFn_DIF   = 6'b011010,
        InstFn_DIVU  = 6'b011011,
        InstFn_JR    = 6'b001000,
        InstFn_JALR  = 6'b001001,
        InstFn_NOR   = 6'b100111,
        InstFn_OR    = 6'b100101,
        InstFn_SLL   = 6'b000000,
        InstFn_SLT   = 6'b101010,
        InstFn_SLLV  = 6'b000100,
        InstFn_SLTU  = 6'b101011,   
        InstFn_SRA   = 6'b000011,
        InstFn_SRL   = 6'b000010,
        InstFn_SRAV  = 6'b000111,
        InstFn_SRLV  = 6'b000110,
        InstFn_SUBU  = 6'b100011,
        InstFn_XOR   = 6'b100110
    } InstFn;    
    
    // R-Type inmstruction format
    //
    typedef struct packed {
        InstOp op;
        logic [4:0] rs;
        logic [4:0] rt;
        logic [4:0] rd;
        logic [4:0] sh;
        InstFn fn;
    } RType;
    
    // I-Type instruction format
    //
    typedef struct packed {
        InstOp op;
        logic [4:0] rs;
        logic [4:0] rt;
        logic [15:0] imm;
    } IType;
    
    // J-Type instruction format
    //
    typedef struct packed {
        InstOp op;
        logic [25:0] addr;
    } JType;
    
    /*
    typedef union packed {
        RType r;
        IType i;
        JType j;
        logic [31:0] raw;
    } Instruction;    
    */
    
    typedef enum logic[4:0] {
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
        ApuOp_SRA,
        AluOp_SRAV,
        AluOp_SRL,
        AluOP_SRLV,
        AluOp_SUB,
        AluOp_SUBU,
        AluOp_XOR,
        AluOp_Unknown
    } AluOp;
endpackage