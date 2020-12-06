interface DataMemoryBus
#(    
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32);
    
    logic [ADDR_WIDTH-1:0] Addr;
    logic                  WrEnable;
    logic [DATA_WIDTH-1:0] WrData;
    logic [DATA_WIDTH-1:0] RdData;
    
    modport Master(
        output Addr,
        input  RdData,
        output WrData,
        output WrEnable);
        
    modport Slave(
        input  Addr,
        output RdData,
        input  WrData,
        input  WrEnable);
    
endinterface
