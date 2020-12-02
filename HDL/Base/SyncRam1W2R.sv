module SyncRam1W2R
#(
    parameter ADDR_WIDTH = 8,
    parameter DATA_WIDTH = 8)
(
    input  logic                  i_Clock,
    input  logic [ADDR_WIDTH-1:0] i_RdAddrA,    
    input  logic [ADDR_WIDTH-1:0] i_RdAddrB,
    input  logic [ADDR_WIDTH-1:0] i_WrAddr,
    input  logic                  i_WrEnable,
    input  logic [DATA_WIDTH-1:0] i_WrData,
    output logic [DATA_WIDTH-1:0] o_RdDataA,
    output logic [DATA_WIDTH-1:0] o_RdDataB);
    
    localparam SIZE = 2**ADDR_WIDTH;
    
    logic [DATA_WIDTH-1:0] Data[SIZE];
    
    always_ff @(posedge i_Clock)
    if (i_WrEnable)
        Data[i_WrAddr] = i_WrData;
        
    assign o_RdDataA = Data[i_RdAddrA];
    assign o_RdDataB = Data[i_RdAddrB];
    
endmodule