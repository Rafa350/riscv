package types;

    typedef enum logic[5:0] {
        InstOp_RType = 6'b000000,
        InstOp_ADDI  = 6'b001001,
        InstOp_ADDIU = 6'b001000,
        InstOp_ANDI  = 6'b001100,
        InstOp_LW    = 6'b100011,
        InstOp_SW    = 6'b101011
    } InstOp;
    
    typedef enum logic[5:0] {
        InstFn_ADD   = 6'b100000,
        InstFn_ADDU  = 6'b100001,
        InstFn_AND   = 6'b100100,
        InstFn_break = 6'b001101,
        InstFn_DIF   = 6'b011010,
        InstFn_DIVU  = 6'b011011
    } InstFn;    

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