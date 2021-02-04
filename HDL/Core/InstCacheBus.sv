interface InstCacheBus;

    import Config::*, Types::*;

    InstAddr addr;                    // Adressa
    Inst     inst [RV_ICACHE_BLOCKS]; // Block d'instruccios
    logic    re;                      // Habilita lectura
    logic    busy;                    // Indica ocupat, operacio no disponible

    modport master(
        output addr,
        input  inst,
        output re,
        input  busy);

    modport slave(
        input  addr,
        output inst,
        input  re,
        output busy);

endinterface
