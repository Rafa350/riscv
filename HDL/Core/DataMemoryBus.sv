interface DataMemoryBus;

    import Types::*;

    DataAddr   addr;   // Addresa en bytes
    DataAccess access; // Tipus d'acces (Byte, Half, Word, Dword)
    logic      wr;     // Sol·licitut una operacio d'escriptura
    logic      rd;     // Sol·licitut una operacio de lectura
    Data       wrData; // Dades per escriure
    Data       rdData; // Dades lleigides
    logic      busy;   // Indica que no por realitzar l'operacio sol·licitada

    modport master(
        output addr,
        output access,
        output wr,
        output rd,
        input  rdData,
        output wrData,
        input  busy);

    modport slave(
        input  addr,
        input  access,
        input  wr,
        input  rd,
        output rdData,
        input  wrData,
        output busy);

endinterface
