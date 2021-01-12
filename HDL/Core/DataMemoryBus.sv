interface DataMemoryBus;

    import Types::*;

    DataAddr   addr;     // Addresa en bytes
    DataAccess access;   // Tipus d'acces (Byte, Half, Word, Dword, QWord)
    logic      wrEnable; // Habilita l'escriptura
    logic      rdEnable; // Habilita la lectura
    Data       wrData;   // Dades a escriure
    Data       rdData;   // Dades lleigides
    logic      busy;     // Indica bus ocupat

    modport master(
        output addr,
        output access,
        output wrEnable,
        output rdEnable,
        input  rdData,
        output wrData,
        input  busy);

    modport slave(
        input  addr,
        input  access,
        input  wrEnable,
        input  rdEnable,
        output rdData,
        input  wrData,
        output busy);

endinterface
