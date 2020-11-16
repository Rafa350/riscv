module Program
#(
    parameter ADDR_WIDTH = 32,
    parameter INST_WIDTH = 32)
(   
    input  logic [ADDR_WIDTH-1:0] i_Addr,
    output logic [INST_WIDTH-1:0] o_Inst);

    localparam SIZE = 24;
        
    logic [7:0] Data[0:SIZE-1];
    
    initial
        $readmemh("../Firmware/build/demo.txt", Data);
        
    always_comb begin
        o_Inst = { Data[i_Addr], Data[i_Addr+1], Data[i_Addr+2], Data[i_Addr+3]};
    end

endmodule