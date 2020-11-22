module RoMemory 
#(
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 32,
    parameter FILE_NAME  = "data.txt")
(
    input  logic [ADDR_WIDTH-1:0] i_Addr,    // Adressa
    output logic [DATA_WIDTH-1:0] o_RdData); // Dades de lectura
    
    localparam SIZE = 2**ADDR_WIDTH;
    localparam unsigned WORD_BYTES = (DATA_WIDTH + 7) / 8;
    
    logic [7:0] Data[SIZE];
    
    if (WORD_BYTES == 1)
        assign o_RdData = 
            {Data[{i_Addr[ADDR_WIDTH-1:2], 2'b00}],
             24'b0};

    if (WORD_BYTES == 2) 
        assign o_RdData = 
            {Data[{i_Addr[ADDR_WIDTH-1:2], 2'b01}],
             Data[{i_Addr[ADDR_WIDTH-1:2], 2'b00}],
             16'b0};
   
    if (WORD_BYTES == 4) 
        assign o_RdData = 
            {Data[{i_Addr[ADDR_WIDTH-1:2], 2'b11}],
             Data[{i_Addr[ADDR_WIDTH-1:2], 2'b10}],
             Data[{i_Addr[ADDR_WIDTH-1:2], 2'b01}],
             Data[{i_Addr[ADDR_WIDTH-1:2], 2'b00}]};
             
    initial
        $readmemh(FILE_NAME, Data);
   
endmodule
