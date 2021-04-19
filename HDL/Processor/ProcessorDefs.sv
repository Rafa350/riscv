package ProcessorDefs;

    import Config::*;

    // Definicions basiques del procesador
    //
    typedef logic [DATA_WIDTH-1:0] Data;         // Dades
    typedef logic [31:0]           Inst;         // Instruccions

    typedef logic [ADDR_WIDTH-1:0] DataAddr;     // Adressa de dades en bytes
    typedef logic [PC_WIDTH-1:0]   InstAddr;     // Adressa d'instruccio en bytes
    typedef logic [REG_WIDTH-1:0]  GPRAddr;      // Adressa de registre GPR (General Purpouse Register)
    typedef logic [4:0]            FPRAddr;      // Adressa de registre FPR (Floating Point >Register)
    typedef logic [11:0]           CSRAddr;      // Adressa de registre CSR (Control & Status Register)

    typedef logic [(DATA_WIDTH/8)-1:0] ByteMask; // Mascara de bytes per access a memoria

endpackage
