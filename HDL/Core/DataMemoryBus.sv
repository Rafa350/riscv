interface DataMemoryBus;

    import Types::*;

    localparam ADDR_WIDTH = $size(DataAddr);
    localparam DATA_WIDTH = $size(Data);
    localparam DATA_BYTES = (DATA_WIDTH + 7) / 8;

    logic [ADDR_WIDTH-1:0] addr;     // Addresa en bytes
    logic [DATA_BYTES-1:0] wrMask;   // Mascara de bytes per escriure
    logic                  wrEnable; // Habilita l'escriptura
    logic                  rdEnable; // Habilita la lectura
    logic [DATA_WIDTH-1:0] wrData;   // Dades a escriure
    logic [DATA_WIDTH-1:0] rdData;   // Dades lleigides

    modport master(
        output addr,
        output wrMask,
        output wrEnable,
        output rdEnable,
        input  rdData,
        output wrData);

    modport slave(
        input  addr,
        input  wrMask,
        input  wrEnable,
        input  rdEnable,
        output rdData,
        input  wrData);

endinterface
