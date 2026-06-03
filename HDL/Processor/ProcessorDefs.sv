// Definicions basiques del procesador, independent de la implementacio
// dels cores, ram, cache, etc
//
package ProcessorDefs;

    typedef logic [Config::DATA_WIDTH-1:0]     Data;     // Dades
    typedef logic [31:0]                       Inst;     // Instruccions

    typedef logic [Config::ADDR_WIDTH-1:0]     DataAddr; // Adressa de dades en bytes
    typedef logic [Config::PC_WIDTH-1:0]       InstAddr; // Adressa d'instruccio en bytes
    typedef logic [Config::REG_WIDTH-1:0]      GPRAddr;  // Adressa de registre GPR (General Purpouse Register)
    typedef logic [4:0]                        FPRAddr;  // Adressa de registre FPR (Floating Point >Register)
    typedef logic [11:0]                       CSRAddr;  // Adressa de registre CSR (Control & Status Register)

    typedef logic [(Config::DATA_WIDTH/8)-1:0] ByteMask; // Mascara per accedir a la memoria fraccionada en bytes

endpackage
