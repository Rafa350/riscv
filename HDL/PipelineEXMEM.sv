module PipelineEXMEM 
#(
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 32,
    parameter PC_WIDTH   = 32,
    parameter REG_WIDTH  = 5) 
(
    // Senyals de control
    input  logic                  i_Clock,        // Clock
    input  logic                  i_Reset,        // Reset

    // Senyals de depuracio
    input  logic [2:0]            i_DbgTag,       // Etiqueta de depuracio
    output logic [2:0]            o_DbgTag,                

    // Senyals de control del pipeline  
    input  logic                  i_Flush,
    input  logic                  i_Stall,

    // Senyals d'entrada al pipeline
    input  logic [PC_WIDTH-1:0]   i_PC,
    input  logic [6:0]            i_InstOP,
    input  logic [DATA_WIDTH-1:0] i_Result,
    input  logic                  i_MemWrEnable,
    input  logic [DATA_WIDTH-1:0] i_MemWrData,
    input  logic [REG_WIDTH-1:0]  i_RegWrAddr,
    input  logic                  i_RegWrEnable,
    input  logic [1:0]            i_RegWrDataSel,

    // Senyals de sortida del pipeline
    output logic [PC_WIDTH-1:0]   o_PC,
    output logic [6:0]            o_InstOP,
    output logic [DATA_WIDTH-1:0] o_Result,
    output logic                  o_MemWrEnable,
    output logic [DATA_WIDTH-1:0] o_MemWrData,
    output logic [REG_WIDTH-1:0]  o_RegWrAddr,
    output logic                  o_RegWrEnable,
    output logic [1:0]            o_RegWrDataSel);
    
    
    localparam [2:0] PP_RESET = 3'b1??;
    localparam [2:0] PP_STALL = 3'b010;
    localparam [2:0] PP_FLUSH = 3'b000;

    
    logic [2:0] PPOp;   
    assign PPOp = {i_Reset, i_Stall, i_Flush};


    always_ff @(posedge i_Clock) begin
        unique casez (PPOp) 
            PP_RESET: begin
                o_PC           <= {PC_WIDTH{1'b0}};
                o_InstOP       <= 7'b0;
                o_Result       <= {DATA_WIDTH{1'b0}};
                o_MemWrEnable  <= 1'b0;
                o_MemWrData    <= {DATA_WIDTH{1'b0}};
                o_RegWrAddr    <= {REG_WIDTH{1'b0}};
                o_RegWrEnable  <= 1'b0;
                o_RegWrDataSel <= 2'b0;
            end

            PP_STALL: begin
                o_PC           <= o_PC;
                o_InstOP       <= o_InstOP;
                o_Result       <= o_Result;
                o_MemWrEnable  <= o_MemWrEnable;
                o_MemWrData    <= o_MemWrData;
                o_RegWrAddr    <= o_RegWrAddr;
                o_RegWrEnable  <= o_RegWrEnable;
                o_RegWrDataSel <= o_RegWrDataSel;
            end
           
            default: begin
                o_PC           <= i_PC;
                o_InstOP       <= i_InstOP;
                o_Result       <= i_Result;
                o_MemWrEnable  <= i_MemWrEnable;
                o_MemWrData    <= i_MemWrData;
                o_RegWrAddr    <= i_RegWrAddr;
                o_RegWrEnable  <= i_RegWrEnable;
                o_RegWrDataSel <= i_RegWrDataSel;
            end
        endcase
        
        o_DbgTag       <= i_DbgTag;
    end


endmodule
