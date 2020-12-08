module RegisterCSR 
#(
    parameter DATA_WIDTH = 32,
    parameter CSR_WIDTH = 12)
(
    // Senals de control
    input  logic                  i_Clock,
    input  logic                  i_Reset,
    
    // Senyals d'acces per ISA
    input  logic [CSR_WIDTH-1:0]  i_Addr,
    input  logic                  i_WrEnable,
    input  logic [DATA_WIDTH-1:0] i_WrData,
    output logic [DATA_WIDTH-1:0] o_RdData
    
    // Senyals d'acces directe
    input logic  [31:0]           i_Time,
    input logic  [31:0]           i_InstRet);
    

    // -------------------------------------------------------------------
    // Contador de cicles
    // -------------------------------------------------------------------
    
    logic [31:0] Cicle;
    
    always_ff @(posedge i_Clock) begin
        if (i_Reset)
            Cicle <= 0;
        else
            Cicle <= Cicle + 1;
    end
    

    // -------------------------------------------------------------------
    // Access RW als registres
    // -------------------------------------------------------------------
    
    CSRAddr addr;
    assign addr = i_Addr;
    
    always_ff @(posedge i_Clock) begin
        if (i_Reset) begin
        end
        else if (i_WrEnable) begin
            case (addr)
            endcase
        end
    end
    
    always_comb begin
        case (addr)
            CSRAddr_CYCLE  : o_WrData = Cicle;
            CSRAddr_TIME   : o_WrData = i_Time;
            CSRAddr_INSTRET: o_WrData = i_InstRet;
        endcase
    end


endmodule
