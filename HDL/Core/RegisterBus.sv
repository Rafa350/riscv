interface RBusIf
#(
    parameter DATA_WIDTH = 32,
    parameter REG_WIDTH  = 5)
(
    logic [REG_WIDTH-1:0]  RdAddrA;
    logic [REG_WIDTH-1:0]  RdAddrB;
    logic [REG_WIDTH-1:0]  WrAddr;
    logic [DATA_WIDTH-1:0] RdDataA;
    logic [DATA_WIDTH-1:0] RdDataB;
    logic [DATA_WIDTH-1:0] WrData;
    logic                  WrEnable;
    
    modport Reader (
        input  RdAddrA,
        input  RdAddrB,
        output RdDataA,
        output RdDataB);

    modport Writer (
        input WrData,
        input WrAddr,
        input WrEnable);
);

endinterface
