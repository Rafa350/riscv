module Uart
(
    input  logic       i_clock,
    input  logic       i_reset,
    
    input  logic       i_phyTX,
    output logic       o_phyRX,

    input  logic [3:0] i_addr,
    input  logic       i_wrEnable,
    input  logic [7:0] i_wrData,
    output logic [7:0] o_rdData);

endmodule
