module Memory
#(
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 32)
(
    input                         i_Clock,
    
    input  logic [ADDR_WIDTH-1:0] i_Addr,
    input  logic                  i_WrEnable,
    input  logic [DATA_WIDTH-1:0] i_WrData,
    output logic [DATA_WIDTH-1:0] o_RdData);
    
    mw_ram ram(
        .clock     (i_Clock),
        .wren      (i_WrEnable),
        .data      (i_WrData),
        .q         (o_RdData),
        .rdaddress (i_Addr[ADDR_WIDTH-1:2]),
        .wraddress (i_Addr[ADDR_WIDTH-1:2]));

endmodule
