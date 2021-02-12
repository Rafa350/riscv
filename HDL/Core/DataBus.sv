interface DataBus;

    import Types::*;

    DataAddr addr;  // Addresa en words
    logic    we;    // Habilita escriptura de dades
    logic    re;    // Habilita la lectura
    ByteMask be;    // Habilita els bytes a escriure
    Data     wdata; // Dades per escriure
    Data     rdata; // Dades lleigides
    logic    busy;  // Indica ocupat, operacio no disponible

    modport master(
        output addr,
        output we,
        output re,
        output be,
        input  rdata,
        output wdata,
        input  busy);

    modport slave(
        input  addr,
        input  we,
        input  re,
        input  be,
        output rdata,
        input  wdata,
        output busy);

endinterface
