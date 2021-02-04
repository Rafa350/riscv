interface InstCoreBus;

    import Types::*;

    InstAddr addr; // Adressa
    logic    re;   // Habilita la lecture
    Inst     inst; // Instruccio
    logic    busy; // Indica ocupat, operacio no disponible

    modport master(
        output addr,
        output re,
        input  inst,
        input  busy);

    modport slave(
        input  addr,
        input  re,
        output inst,
        output busy);

endinterface
