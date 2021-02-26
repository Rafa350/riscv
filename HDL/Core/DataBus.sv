interface DataBus;

    import Types::*;

    DataAddr addr;  // Addresa en words
    logic    re;    // Habilita la lectura
    logic    we;    // Habilita escriptura de dades
    ByteMask wb;    // Mascara dels bytes a escriure
    Data     wdata; // Dades per escriure
    Data     rdata; // Dades lleigides
    logic    busy;  // Indica ocupat, operacio no disponible

    modport master(
        output addr,
        output re,
        output we,
        output wb,
        input  rdata,
        output wdata,
        input  busy);

    modport slave(
        input  addr,
        input  re,
        input  we,
        input  wb,
        output rdata,
        input  wdata,
        output busy);

endinterface
