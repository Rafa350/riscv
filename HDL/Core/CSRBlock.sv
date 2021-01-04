module CSRBlock
    parameter DATA_WIDTH = 32,
    parameter CSR_WIDTH = 12)
(
    // Senals de control
    input  logic                  i_clock,
    input  logic                  i_reset,
    
    // Senyals d'acces per ISA
    input  logic [CSR_WIDTH-1:0]  i_addr,
    input  logic                  i_wrEnable,
    input  Data                   i_wrData,
    output Data                   o_rdData
    
    // Senyals d'acces directe
    input logic  [31:0]           i_time,
    input logic  [31:0]           i_instRet);
    
    
    typedef enum logic [11:0] {
        CSRAddr_USTATUS  = 12'h000,
        CSRAddr_UIE      = 12'h004,
        CSRAddr_UTVEC    = 12'h005,

        CSRAddr_USCRATCH = 12'h040,
        CSRAddr_UEPC     = 12'h041,
        CSRAddr_UCAUSE   = 12'h042,
        CSRAddr_UTVAL    = 12'h043,
        CSRAddr_UIP      = 12'h044,

        CSRAddr_FFLAGS   = 12'h001,
        CSRAddr_FRM      = 12'h002,
        CSRAddr_FCSR     = 12'h003,

        CSRAddr_CYCLE    = 12'hC00,
        CSRAddr_TIME     = 12'hC01,
        CSRAddr_INSTRET  = 12'hC02,

        CSRAddr_CYCLEH   = 12'hC80,
        CSRAddr_TIMEH    = 12'hC81,
        CSRAddr_INSTRETH = 12'hC82
    } CSRAddr;
    
    
    // -------------------------------------------------------------------
    // Contador de cicles
    // -------------------------------------------------------------------
    
    logic [31:0] cicle;
    
    always_ff @(posedge i_clock) begin
        if (i_reset)
            cicle <= 0;
        else
            cicle <= cicle + 1;
    end
    

    // -------------------------------------------------------------------
    // Access RW als registres
    // -------------------------------------------------------------------
    
    CSRAddr addr;
    assign addr = i_addr;
    
    always_ff @(posedge i_clock) begin
        if (i_reset) begin
        end
        else if (i_wrEnable) begin
            case (addr)
            endcase
        end
    end
    
    always_comb begin
        case (addr)
            CSRAddr_CYCLE  : o_wrData = cicle;
            CSRAddr_TIME   : o_wrData = i_time;
            CSRAddr_INSTRET: o_wrData = i_instRet;
        endcase
    end


endmodule
