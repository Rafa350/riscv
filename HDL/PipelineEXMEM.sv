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
    input  logic                  i_Flush,        // Descarta les acciona d'escriptura

    // Senyals de depuracio
    input  logic [2:0]            i_DbgTag,       // Etiqueta de depuracio
    output logic [2:0]            o_DbgTag,

    // Senyals d'entrada al pipeline
    input  logic [PC_WIDTH-1:0]   i_PC,
    input  logic [6:0]            i_InstOP,
    input  logic [DATA_WIDTH-1:0] i_Result,
    input  logic [DATA_WIDTH-1:0] i_DataB,
    input  logic                  i_MemWrEnable,  // Autoritza l'escriptura en la memoria
    input  logic [REG_WIDTH-1:0]  i_RegWrAddr,
    input  logic                  i_RegWrEnable,  // Autoritza l'escriptura en els registres
    input  logic [1:0]            i_RegWrDataSel, 

    // Senyals de sortida del pipeline
    output logic [PC_WIDTH-1:0]   o_PC,
    output logic [6:0]            o_InstOP,
    output logic [DATA_WIDTH-1:0] o_Result,
    output logic [DATA_WIDTH-1:0] o_DataB,
    output logic                  o_MemWrEnable,
    output logic [REG_WIDTH-1:0]  o_RegWrAddr,
    output logic                  o_RegWrEnable,
    output logic [1:0]            o_RegWrDataSel);


    always_ff @(posedge i_Clock) begin
        o_PC           <= i_Reset ? {PC_WIDTH{1'b0}}   : i_PC;
        o_InstOP       <= i_Reset ? 7'b0               : i_InstOP;
        o_Result       <= i_Reset ? {DATA_WIDTH{1'b0}} : i_Result;
        o_DataB        <= i_Reset ? {DATA_WIDTH{1'b0}} : i_DataB;
        o_MemWrEnable  <= i_Reset ? 1'b0               : (i_Flush ? 1'b0 : i_MemWrEnable);
        o_RegWrAddr    <= i_Reset ? {REG_WIDTH{1'b0}}  : i_RegWrAddr;
        o_RegWrEnable  <= i_Reset ? 1'b0               : (i_Flush ? 1'b0 : i_RegWrEnable);
        o_RegWrDataSel <= i_Reset ? 2'b0               : i_RegWrDataSel;
        o_DbgTag       <= i_Reset ? 3'b0               : i_DbgTag;
    end

endmodule
