interface DataMemoryBus;

    import Types::*;

    DataAddr   addr;     // Addresa en bytes
    logic[3:0] wrEnable; // Autoritzacio d'escriptura per bytes
    Data       wrData;   // Dades per escriure
    Data       rdData;   // Dades lleigides

    modport master(
        output addr,
        input  rdData,
        output wrData,
        output wrEnable);

    modport slave(
        input  addr,
        output rdData,
        input  wrData,
        input  wrEnable);

endinterface
