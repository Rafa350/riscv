module PipelineMEMWB
#(
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 32,
    parameter PC_WIDTH   = 32,
    parameter REG_WIDTH  = 5) 
(
    // Senyals de control
    input  logic                  i_Clock,
    input  logic                  i_Reset,
    
    // Senyals de depuracio
    input  logic [2:0]            i_DbgTag,
    output logic [2:0]            o_DbgTag,                   
    
    // Senyals de control del pipeline  
    input  logic                i_Flush,
    input  logic                i_Stall,

    // Senyals d'entrada al pipeline
    input  logic [6:0]            i_InstOP,
    input  logic [REG_WIDTH-1:0]  i_RegWrAddr,
    input  logic                  i_RegWrEnable,
    input  logic [DATA_WIDTH-1:0] i_RegWrData,
    
    // Senyal de sortida del pipeline
    //
    output logic [6:0]            o_InstOP,
    output logic [REG_WIDTH-1:0]  o_RegWrAddr,
    output logic                  o_RegWrEnable,
    output logic [DATA_WIDTH-1:0] o_RegWrData);

    localparam [2:0] PP_RESET = 3'b1??;
    localparam [2:0] PP_STALL = 3'b010;
    localparam [2:0] PP_FLUSH = 3'b000;
    
    
    logic [2:0] PPOp;
    assign PPOp = {i_Reset, i_Stall, i_Flush};

    always_ff @(posedge i_Clock) begin
        unique casez (PPOp)
            PP_RESET: begin
                o_InstOP      <= 7'b0;
                o_RegWrAddr   <= {REG_WIDTH{1'b0}};
                o_RegWrEnable <= 1'b0;
                o_RegWrData   <= {DATA_WIDTH{1'b0}};
            end
            
            PP_STALL: begin
                o_InstOP      <= o_InstOP;
                o_RegWrAddr   <= o_RegWrAddr;
                o_RegWrEnable <= o_RegWrEnable;
                o_RegWrData   <= o_RegWrData;
            end
            
            default: begin
                o_InstOP      <= i_InstOP;
                o_RegWrAddr   <= i_RegWrAddr;
                o_RegWrEnable <= i_RegWrEnable;
                o_RegWrData   <= i_RegWrData;
            end
        endcase
        
        o_DbgTag      <= i_DbgTag;
    end

endmodule
