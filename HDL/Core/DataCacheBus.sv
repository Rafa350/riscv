interface DataCacheBus;

    import Config::*, Types::*;

    DataAddr   addr;                     // Addresa en bytes
    DataAccess access;                   // Tipus d'acces (Byte, Half, Word, Dword)
    logic      we;                       // Habilita escriptura de dades
    logic      re;                       // Habilita lectura de dades
    Data       wdata [RV_DCACHE_BLOCKS]; // Bloc de dades per escriure
    Data       rdata [RV_DCACHE_BLOCKS]; // Bloc de dades lleigides
    logic      busy;                     // Indica ocupat, operacio no disponible

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
