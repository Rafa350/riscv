interface RBusIf
#(
    parameter DATA_WIDTH = 32,
    parameter REG_WIDTH  = 5)
(
    logic [REG_WIDTH-1:0]  rdAddrA;
    logic [REG_WIDTH-1:0]  rdAddrB;
    logic [REG_WIDTH-1:0]  wrAddr;
    logic [DATA_WIDTH-1:0] rdDataA;
    logic [DATA_WIDTH-1:0] rdDataB;
    logic [DATA_WIDTH-1:0] wrData;
    logic                  wrEnable;
    
    modport reader (
        output rdAddrA,
        output rdAddrB,
        input  rdDataA,
        input  rdDataB);

    modport writer (
        output wrData,
        output wrAddr,
        output wrEnable);
);

endinterface
