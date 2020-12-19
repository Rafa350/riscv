interface InstMemoryBus;

    import Types::*;

    InstAddr addr;
    Inst     inst;

    modport master(
        output addr,
        input  inst);

    modport slave(
        input  addr,
        output inst);

endinterface
