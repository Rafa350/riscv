module Uart
(
    input  logic       i_clock,
    input  logic       i_reset,
    
    input  logic       o_tx,
    output logic       i_rx,

    input  logic [3:0] i_addr,
    input  logic       i_wrEnable,
    input  logic [7:0] i_wrData,
    output logic [7:0] o_rdData);
    
    
    UART_Baud
    uartBaud(
        .i_clock (i_clock),
        .i_reset (i_reset));
    
    UART_TX
    uartTx();

endmodule
