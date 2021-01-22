interface RegisterBus;

    import Types::*;

    RegAddr rdAddrA;
    RegAddr rdAddrB;
    RegAddr wrAddr;
    Data    rdDataA;
    Data    rdDataB;
    Data    wrData;
    logic   wr;

    modport masterReader(
        output rdAddrA,
        output rdAddrB,
        input  rdDataA,
        input  rdDataB);

    modport slaveReader(
        input  rdAddrA,
        input  rdAddrB,
        output rdDataA,
        output rdDataB);

    modport masterWriter(
        output  wrAddr,
        output  wrData,
        output  wr);

    modport slaveWriter(
        input wrAddr,
        input wrData,
        input wr);

endinterface
