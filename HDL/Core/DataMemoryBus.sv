interface DataMemoryBus
#(
    parameter DATA_BYTES = 4);

    import Types::*;

    localparam DATA_WIDTH = $size(Data);

    DataAddr   addr;     // Addresa en bytes
    DataAccess access;   // Tamany de dades
    logic      wrEnable; // Habilita l'escriptura
    logic      rdEnable; // Habilita la lectura
    Data       wrData;   // Dades a escriure
    Data       rdData;   // Dades lleigides

    modport master(
        output addr,
        output access,
        output wrEnable,
        output rdEnable,
        input  rdData,
        output wrData);

    modport slave(
        input  addr,
        input  access,
        input  wrEnable,
        input  rdEnable,
        output rdData,
        input  wrData);

endinterface
