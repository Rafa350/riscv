module UART_TX
(
    input  logic       i_clock, // Clock
    input  logic       i_reset, // Reset
    
    input  logic [7:0] i_data,  // Dades a tramsmitir
    input  logic       i_we,    // Habilita l'escriptura de dades
    
    input  logic       i_ce;    // Habilita el puls de transmissio
    output logic       o_busy,  // Indica que esta ocupat

    output logic       o_tx);   // Pin de sortida


    localparam WORD_LENGTH = 8;
    
    
    typedef enum logic [1:0] {
        State_IDLE,
        State_START,
        State_DATA,
        State_STOP
    } State;
    
    
    State state;
    logic [7:0] data;
    logic [3:0] bitPos;

    always_ff @(posedge i_clock) 
        if (i_reset)
            state <= State_IDLE;
       
        else
            unique case (state)
                State_IDLE: // En espera d'instruccions
                    if (i_we) begin
                        data <= i_data;
                        o_tx <= 1'b1;
                        state <= State_START;
                    end
                    
                State_START: // Transmissio del bit START
                    if (i_ce) begin
                        o_tx <= 1'b0;
                        bitPos <= 0;
                        state <= State_DATA;
                    end
                    
                State_DATA: // Transmiteix les dades
                    if (i_ce) begin
                        o_tx <= data[bitPos];
                        if (bitPos == WORD_LENGTH) 
                            state <= State_STOP;
                        else
                            bitPos <= bitPos + 1;
                    end
                    
                State_STOP: // Transmiteix el bit STOP
                    iof (i_ce) begin
                        o_tx <= 1'b1;
                        nextState <= State_IDLE;
                    end
            endcase
                
endmodule
    