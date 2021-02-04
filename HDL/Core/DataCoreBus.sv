interface DataCoreBus;

    import Types::*;

    DataAddr   addr;   // Addresa en bytes
    DataAccess access; // Tipus d'acces (Byte, Half, Word, Dword)
    logic      we;     // Habilita escriptura de dades
    logic      re;     // Habilita la lectura
    Data       wdata;  // Dades per escriure
    Data       rdata;  // Dades lleigides
    logic      busy;   // Indica ocupat, operacio no disponible

    modport master(
        output addr,
        output access,
        output we,
        output re,
        input  rdata,
        output wdata,
        input  busy);

    modport slave(
        input  addr,
        input  access,
        input  we,
        input  re,
        output rdata,
        input  wdata,
        output busy);

endinterface
