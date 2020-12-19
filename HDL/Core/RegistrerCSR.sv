module RegisterCSR 
#(
    parameter DATA_WIDTH = 32,
    parameter CSR_WIDTH = 12)
(
    // Senals de control
    input  logic                  i_clock,
    input  logic                  i_reset,
    
    // Senyals d'acces per ISA
    input  logic [CSR_WIDTH-1:0]  i_addr,
    input  logic                  i_wrEnable,
    input  logic [DATA_WIDTH-1:0] i_wrData,
    output logic [DATA_WIDTH-1:0] o_rdData
    
    // Senyals d'acces directe
    input logic  [31:0]           i_time,
    input logic  [31:0]           i_instRet);
    

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
