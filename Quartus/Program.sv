module Program
#(
    parameter ADDR_WIDTH = 32,
    parameter INST_WIDTH = 32)
(   
    input  logic [ADDR_WIDTH-1:0] i_Addr,
    output logic [INST_WIDTH-1:0] o_Inst);

    localparam SIZE = 38;
        
    logic [31:0] Data[0:SIZE-1];
           
    always_comb 
        o_Inst = Data[i_Addr];

    initial
        $readmemh("../build/Firmware/main.txt", Data);

endmodule