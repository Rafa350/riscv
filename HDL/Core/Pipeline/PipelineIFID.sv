module PipelineIFID 
#(
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 32,
    parameter PC_WIDTH   = 32,
    parameter REG_WIDTH  = 5) 
(
    // Senyals de control
    input  logic                i_Clock,   // Clock
    input  logic                i_Reset,   // Reset
    input  logic                i_Stall,   // Dehabilita l'anvançament
    
    // Senyals d'entrada de depuracio
    input  logic [7:0]          i_DbgTag,  // Etiqueta
    input  logic [PC_WIDTH-1:0] i_DbgPC,   // PC
    input  logic [31:0]         i_DbgInst, // Instruccio 
    
    // Senyalas de sortida de depuracio
    output logic [7:0]          o_DbgTag,  // Etiqueta
    output logic [PC_WIDTH-1:0] o_DbgPC,   // PC
    output logic [31:0]         o_DbgInst, // Instruccio 

    // Senyals d'entrada al pipeline  
    input  logic [PC_WIDTH-1:0] i_PC,      // Contador d eprograma
    input  logic [31:0]         i_Inst,    // Instruccio
    
    // Senyals de sortida del pipeline
    output logic [PC_WIDTH-1:0] o_PC,      // Contador de programa
    output logic [31:0]         o_Inst);   // Instruccio


    always_ff @(posedge i_Clock) begin
        o_PC      <= i_Reset ? -4    : (i_Stall ? o_PC   : i_PC);
        o_Inst    <= i_Reset ? 32'b0 : (i_Stall ? o_Inst : i_Inst);
        
        o_DbgTag  <= i_Reset ? 8'b0             : (i_Stall ? o_DbgTag  : i_DbgTag);
        o_DbgPC   <= i_Reset ? {PC_WIDTH{1'b0}} : (i_Stall ? o_DbgPC   : i_DbgPC);
        o_DbgInst <= i_Reset ? 32'b0            : (i_Stall ? o_DbgInst : i_DbgInst);
    end


endmodule
