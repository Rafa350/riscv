#include "sim.h"

// Tipus d'instruccio (Intruction Type)
//
#define LIT             0x8000
#define JMP             0x0000
#define BRZ             0x2000
#define JSR             0x4000
#define DO              0x6000

// Operacio amb la ALU
//
#define OP_T            0x0000
#define OP_N            0x0100
#define OP_TaddN        0x0200
#define OP_TandN        0x0300
#define OP_TorN         0x0400
#define OP_TxorN        0x0500
#define OP_notT         0x0600
#define OP_NeqT         0x0700
#define OP_NltT         0x0800
#define OP_Tright       0x0900
#define OP_Tleft        0x0A00

// Operacio amb el D-Stack
//
#define Ddec            0x0003  // Dsp--
#define Dinc            0x0001  // Dsp++

// Operacio amb el R-Stack
//
#define Rdec            0x000C  // Rsp--
#define Rinc            0x0004  // Rsp++

// Operacio de transferencia
//
#define TtoN            0x0010  // Mou T a N
#define TtoR            0x0020  // Mou T a R
#define NtoMEM          0x0030  // Mou N a ram[T]
#define NtoIO           0x0040  // Mou N a io[T]

// Sufixos de la intruccio DO
//
#define _RET            | 0x1000 | Rdec

// Instruccions literals (LIT)
//
#define PUSH(a)         (LIT | ((a) & 0x7FFF))

// Instruccions de salt (JMP, JUMPZ, CALL, RET)
//
#define JUMP(a)         (JMP | ((a) & 0x1FFF))
#define JUMPZ(a)        (BRZ | ((a) & 0x1FFF))
#define CALL(a)         (JSR | ((a) & 0x1FFF))
#define RET             (DO _RET)

// Instruccions ALU            op-code     mov    dsp    rsp
//                           +-----------+------+------+------+
#define ADD             (DO  | OP_TaddN  | 0    | Ddec | 0    )
#define AND             (DO  | OP_TandN  | 0    | Ddec | 0    }
#define DROP            (DO  | OP_N      | 0    | Ddec | 0    )
#define DUP             (DO  | OP_T      | TtoN | Dinc | 0    )
#define EQ              (DO  | OP_TeqN   | 0    | Ddec | 0    )
#define EXIT    (DO | 0x1000 | OP_T      | 0    | 0    | Rdec )
#define INVERT          (DO  | OP_notT   | 0    | 0    | 0    )
#define LT              (DO  | OP_TgtN   | 0    | Ddec | 0    )
#define NIP             (DO  | OP_T      | 0    | Ddec | 0    ) 
#define NOOP            (DO  | OP_T      | 0    | 0    | 0    )
#define OR              (DO  | OP_TorN   | 0    | Ddec | 0    )
#define OVER            (DO  | OP_N      | TtoN | Dinc | 0    )
#define READ            (DO  | OP_MEM    | 0    | 0    | 0    )
#define SWAP            (DO  | OP_T      | TtoN | 0    | 0    )
#define WRITE           (DO  | OP_N      | 0    | 0    | 0    )
#define XOR             (DO  | OP_TxorN  | 0    | Ddec | 0    }



static unsigned data[] = {
    /*  0 */ PUSH(0x55),
    /*  1 */ INVERT,
    /*  2 */ PUSH(0x1C),
    /*  3 */ CALL(10),
    /*  4 */ CALL(16),
    /*  5 */ JUMP(0),
    /*  6 */ 0,
    /*  7 */ 0,
    /*  8 */ 0,
    /*  9 */ 0,

    /* 10 */ PUSH(0x2A),
    /* 11 */ PUSH(0x2B),
    /* 12 */ PUSH(0x2C),
    /* 13 */ DROP,
    /* 14 */ DROP,
    /* 15 */ DROP _RET,

    /* 16 */ PUSH(0x50),
    /* 17 */ PUSH(0x01),
    /* 18 */ ADD,
    /* 19 */ DROP _RET,
    /* 20 */ 0,
};


ROM::ROM() {
    
    mem = data;
    memSize = sizeof(data) / sizeof(data[0]);
}


ROM::ROM(const char *fileName) {
    
    mem = NULL;
    memSize = 0;
}


unsigned ROM::get(unsigned addr) const {
    
    if ((mem == NULL) || (addr >= memSize))
        return 0;

    return mem[addr];
}
