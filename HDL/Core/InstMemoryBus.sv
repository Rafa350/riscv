interface InstMemoryBus
#(    
    parameter PC_WIDTH = 32);
    
    logic [PC_WIDTH-1:0] Addr;
    logic [31:0] Inst;
    
    modport Master(
        output Addr,
        input  Inst);
        
    modport Slave(
        input  Addr,
        output Inst);
    
endinterface
