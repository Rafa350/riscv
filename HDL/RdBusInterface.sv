interface  RdBusInterface #(
    DATA_WIDTH = 32,
    ADDR_WIDTH = 32);

    logic [DATA_WIDTH-1:0] RdData;
    logic [ADDR_WIDTH-1:0] Addr;
    
    modport Master ( 
        output Addr,
        input  RdData);
    
    modport Slave (
        input Addr,
        output RdData);
        
endinterface
