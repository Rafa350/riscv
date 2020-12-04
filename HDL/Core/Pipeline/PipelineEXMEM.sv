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

    // Senyals d'entrada de depuracio
    input  logic [7:0]            i_DbgTag,       // Etiqueta
    input  logic [PC_WIDTH-1:0]   i_DbgPC,        // PC
    input  logic [31:0]           i_DbgInst,      // Instruccio
    
    // Senyals de sortidas de depuracio
    output logic [7:0]            o_DbgTag,       // Etiqueta
    output logic [PC_WIDTH-1:0]   o_DbgPC,        // PC
    output logic [31:0]           o_DbgInst,      // Instruccio

    // Senyals d'entrada al pipeline
    input  logic [PC_WIDTH-1:0]   i_PC,
    input  logic [6:0]            i_InstOP,
    input  logic [DATA_WIDTH-1:0] i_Result,
    input  logic [DATA_WIDTH-1:0] i_DataB,
    input  logic                  i_MemWrEnable,  // Autoritza l'escriptura en la memoria
    input  logic [REG_WIDTH-1:0]  i_RegWrAddr,
    input  logic                  i_RegWrEnable,  // Autoritza l'escriptura en els registres
    input  logic [1:0]            i_RegWrDataSel, 
    input  logic                  i_IsLoad,      

    // Senyals de sortida del pipeline
    output logic [PC_WIDTH-1:0]   o_PC,
    output logic [6:0]            o_InstOP,
    output logic [DATA_WIDTH-1:0] o_Result,
    output logic [DATA_WIDTH-1:0] o_DataB,
    output logic                  o_MemWrEnable,
    output logic [REG_WIDTH-1:0]  o_RegWrAddr,
    output logic                  o_RegWrEnable,
    output logic [1:0]            o_RegWrDataSel,
    output logic                  o_IsLoad);


    always_ff @(posedge i_Clock) begin
        o_PC           <= i_Reset ? {PC_WIDTH{1'b0}}   : i_PC;
        o_InstOP       <= i_Reset ? 7'b0               : i_InstOP;
        o_Result       <= i_Reset ? {DATA_WIDTH{1'b0}} : i_Result;
        o_DataB        <= i_Reset ? {DATA_WIDTH{1'b0}} : i_DataB;
        o_MemWrEnable  <= i_Reset ? 1'b0               : (i_Flush ? 1'b0 : i_MemWrEnable);
        o_RegWrAddr    <= i_Reset ? {REG_WIDTH{1'b0}}  : i_RegWrAddr;
        o_RegWrEnable  <= i_Reset ? 1'b0               : (i_Flush ? 1'b0 : i_RegWrEnable);
        o_RegWrDataSel <= i_Reset ? 2'b0               : i_RegWrDataSel;
        o_IsLoad       <= i_Reset ? 1'b0               : i_IsLoad;
        
        o_DbgTag       <= i_Reset ? 8'b0               : i_DbgTag;
        o_DbgPC        <= i_Reset ? {PC_WIDTH{1'b0}}   : i_DbgPC;
        o_DbgInst      <= i_Reset ? 32'b0              : i_DbgInst;
    end

endmodule
