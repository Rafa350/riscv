interface DataBus;

    import ProcessorDefs::*;

    DataAddr addr;  // Addresa en words
    logic    re;    // Habilita la lectura
    logic    we;    // Habilita escriptura de dades
    ByteMask be;    // Mascara dels bytes a escriure
    Data     wdata; // Dades per escriure
    Data     rdata; // Dades lleigides
    logic    busy;  // Indica ocupat, operacio no disponible

    modport master(
        output addr,
        output re,
        output we,
        output be,
        input  rdata,
        output wdata,
        input  busy);

    modport slave(
        input  addr,
        input  re,
        input  we,
        input  be,
        output rdata,
        input  wdata,
        output busy);

endinterface
