interface InstBus;

    import Types::*;

    InstAddr addr; // Adressa
    Inst     inst; // Instruccio
    logic    re;   // Habilita lectura
    logic    busy; // Indica ocupat, operacio no disponible

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
