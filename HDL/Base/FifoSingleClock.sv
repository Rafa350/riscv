Pendent de verificar

module FifoSingleClock
#(
    parameter DATA_WIDTH = 8,
    parameter QUEUE_LENGTH = 4)
(
    input  logic                  i_clock,
    input  logic                  i_reset,
    
    input  logic [DATA_WIDTH-1:0] i_wrData,
    input  logic                  i_wrEnable,
    
    output logic [DATA_WIDTH-1:0] o_rdData,
    input  logic                  i_rdEnable,
    
    output logic                  o_canWrite,
    output logic                  o_canRead);
    
    localparam ADDR_WIDTH = $clog2(QUEUE_LENGTH);
    
    logic [DATA_WIDTH-1:0] data[0:QUEUE_LENGTH-1];
    logic [ADDR_WIDTH-1:0] wrAddr;
    logic [ADDR_WIDTH-1:0] rdAddr;
    logic [ADDR_WIDTH-1:0] count;
    logic wrLock;
    logic rdLock;
    
    assign o_canWrite = count != QUEUE_LENGTH;
    assign o_canRead  = count != 0;

    always_ff @(posedge i_clock) begin
    
        // Gestio de l'escriptura
        //
        unique casez ({i_reset, i_wrEnable, wrLock, o_canWrite})
            4'b1_???: // Reset
                begin
                    wrAddr <= 'b0;
                    wrLock <= 'b0;
                end
                
            4'b0_100: // Escriptura 
                begin
                    data[WrAddr] <= i_wrData;
                    wrAddr       <= (wrAddr == QUEUE_LENGTH - 1) ? 'b0 : wrAddr + 'b1;
                    wrLock       <= 'b1;
                end
                
            4'b0_01?: // Desbloqueig d'escriptura
                wrLock <= 'b0;
        endcase
        
        // Gestio de la lectura
        //
        unique casez ({i_reset, i_rdEnable, rdLock, o_canWrite})
            4'b1_000: // Reset
                begin
                    rdAddr <= 0;
                    rdLock <= 0;
                end
                
            4'b0_100: // Lectura
                begin
                    o_rdData <= Data[RdAddr];
                    rdAddr   <= (rdAddr == QUEUE_LENGTH - 1) ? 'b0 : rdAddr + 'b1;
                    rdLock   <= 'b1;
                end
                
            4'b0_00?: // Desbloqueig de lectura
                rdLock <= 'b0;
        endcase
    
        // Gestiona el contador
        //
        unique casez ({i_reset, i_wrEnable, wrLock, i_rdEnable, rdLock})
            5'b1_????: count <= 0;
            5'b0_100?: count <= count + 'b1;
            5'b0_0?10: count <= count - 'b1;
            default  : count <= count;
        endcase
    end
        

endmodule
