module UART_Baud
(
    input logic i_clock,
    input logic i_reset,
    
    output logic o_txce,
    output logic o_rxce);
    
    parameter RX_ACC_MAX = 50000000 / (115200 * 16);
    parameter TX_ACC_MAX = 50000000 / 115200;
    parameter RX_ACC_WIDTH = $clog2(RX_ACC_MAX);
    parameter TX_ACC_WIDTH = $clog2(TX_ACC_MAX);
    
    logic [RX_ACC_WIDTH-1:0] rx_acc = 0;
    logic [TX_ACC_WIDTH-1:0] tx_acc = 0;

    assign o_rxce = rx_acc == 0;
    assign o_txce = tx_acc == 0;

    always_ff @(posedge i_clock) begin
        if (i_reset | (rx_acc == RX_ACC_MAX[RX_ACC_WIDTH-1:0]))
            rx_acc <= 0;
        else
            rx_acc <= rx_acc + {{RX_ACC_WIDTH-1{1'b0}, 1'b1};

        if (i_reset | (tx_acc == TX_ACC_MAX[TX_ACC_WIDTH-1:0]))
            tx_acc <= 0;
        else
            tx_acc <= tx_acc + {{TX_ACC_WIDTH-1{1'b0}, 1'b1};
    end
    
endmodule
    