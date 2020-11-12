interface  RdWrBusInterface #(
    DATA_WIDTH = 32,
    ADDR_WIDTH = 32);

    logic [DATA_WIDTH-1:0] RdData;
    logic [DATA_WIDTH-1:0] WrData;
    logic [ADDR_WIDTH-1:0] Addr;
    logic                  WrEnable;
    
    modport Master ( 
        output Addr,
        input  RdData,        
        output WrData, 
        output WrEnable);
    
    modport Slave (
        input  Addr,
        input  WrData,
        output RdData,
        input  WrEnable); 
        
endinterface
