interface InstMemoryBus;

    import Types::*;

    InstAddr addr; // Adressa
    Inst     inst; // Instruccio
    logic    rd;   // Sol·licitut una operacio de lectura
    logic    busy; // Indica que no por realitzar l'operacio sol·licitada

    modport master(
        output addr,
        input  inst,
        output rd,
        input  busy);

    modport slave(
        input  addr,
        output inst,
        input  rd,
        output busy);

endinterface
