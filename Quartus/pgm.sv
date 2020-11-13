import types::*;


module pgm
#(
    parameter ADDR_WIDTH = 32,
    parameter INST_WIDTH = 32)
(   
    RdBusInterface.Slave io_PgmBus);
    
    logic [ADDR_WIDTH-1:0] addr;
    logic [7:0] data[0:1024];
    
    initial
        $readmemh("../Firmware/demo.txt", data);
        
    always_comb begin
        addr = io_PgmBus.Addr;
        io_PgmBus.RdData = { data[addr], data[addr+1], data[addr+2], data[addr+3]};
    end

endmodule