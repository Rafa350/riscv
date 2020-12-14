module Synchronizer
#(
    parameter DATA_WIDTH = 8)
(
    input  logic                  i_Clock,
    input  logic                  i_Reset,
    input  logic [DATA_WIDTH-1:0] i_Data,
    output logic [DATA_WIDTH-1:0] o_Data);

    logic [DATA_WIDTH-1:0] Data;
    
    always_ff @(posedge i_Clock)
        if (i_Reset)
            {o_Data, Data} <= 'b0;
        else
            {o_Data, Data} <= {Data, i_Data};

endmodule
