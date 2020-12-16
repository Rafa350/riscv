Pendent de verificar

module FifoSingleClock
#(
    parameter DATA_WIDTH = 8,
    parameter QUEUE_LENGTH = 4)
(
    input  logic                  i_Clock,
    input  logic                  i_Reset,
    
    input  logic [DATA_WIDTH-1:0] i_WrData,
    input  logic                  i_WrEnable,
    
    output logic [DATA_WIDTH-1:0] o_RdData,
    input  logic                  i_RdEnable,
    
    output logic                  o_CanWrite,
    output logic                  o_CanRead);
    
    localparam ADDR_WIDTH = $clog2(QUEUE_LENGTH);
    
    logic [DATA_WIDTH-1:0] Data[0:QUEUE_LENGTH-1];
    logic [ADDR_WIDTH-1:0] WrAddr;
    logic [ADDR_WIDTH-1:0] RdAddr;
    logic [ADDR_WIDTH-1:0] Count;
    logic WrLock;
    logic RdLock;
    
    assign o_CanWrite = Count != QUEUE_LENGTH;
    assign o_CanRead  = Count != 0;

    always_ff @(posedge i_Clock) begin
    
        // Gestio de l'escriptura
        //
        unique casez ({i_Reset, i_WrEnable, WrLock, o_CanWrite})
            4'b1_???: // Reset
                begin
                    WrAddr <= 'b0;
                    WrLock <= 'b0;
                end
                
            4'b0_100: // Escriptura 
                begin
                    Data[WrAddr] <= i_WrData;
                    WrAddr       <= (WrAddr == QUEUE_LENGTH - 1) ? 'b0 : WrAddr + 'b1;
                    WrLock       <= 'b1;
                end
                
            4'b0_01?: // Desbloqueig d'escriptura
                WrLock <= 'b0;
        endcase
        
        // Gestio de la lectura
        //
        unique casez ({i_Reset, i_RdEnable, RdLock, o_CanWrite})
            4'b1_000: // Reset
                begin
                    RdAddr <= 0;
                    RdLock <= 0;
                end
                
            4'b0_100: // Lectura
                begin
                    o_RdData <= Data[RdAddr];
                    RdAddr   <= (RdAddr == QUEUE_LENGTH - 1) ? 'b0 : RdAddr + 'b1;
                    RdLock   <= 'b1;
                end
                
            4'b0_00?: // Desbloqueig de lectura
                RdLock <= 'b0;
        endcase
    
        // Gestiona el contador
        //
        unique casez ({i_Reset, i_WrEnable, WrLock, i_RdEnable, RdLock})
            5'b1_????: Count <= 0;
            5'b0_100?: Count <= Count + 'b1;
            5'b0_0?10: Count <= Count - 'b1;
            default  : Count <= Count;
        endcase
    end
        

endmodule
