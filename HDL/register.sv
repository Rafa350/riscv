module Register
#(
    parameter WIDTH = 32,
    parameter INIT = 0)
(
    input  logic             i_Clock,
    input  logic             i_Reset,
    
    input  logic             i_WrEnable,
   
    input  logic [WIDTH-1:0] i_WrData,
    output logic [WIDTH-1:0] o_RdData);
    
    logic [WIDTH-1:0] Data;

    initial
        Data = INIT;
      
    always_ff @(posedge i_Clock)
        case ({i_Reset, i_WrEnable})
            2'b00: Data <= Data;
            2'b01: Data <= i_WrData;
            2'b10: Data <= INIT;
            2'b11: Data <= INIT;
        endcase
        
    assign o_RdData = i_Reset ? INIT : Data;        
    
endmodule
