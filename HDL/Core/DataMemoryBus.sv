interface DataMemoryBus;

    import Types::*;

    DataAddr addr;
    logic    wrEnable;
    Data     wrData;
    Data     rdData;

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
