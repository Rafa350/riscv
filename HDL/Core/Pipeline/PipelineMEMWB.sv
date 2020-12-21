`include "RV.svh"


module PipelineMEMWB
    import Types::*;
(
    // Senyals de control
    input  logic    i_clock,          // Clock
    input  logic    i_reset,          // Reset
    input  logic    i_flush,          // Descarta les accions d'escriptura

`ifdef DEBUG
    // Senyals d'entrada de depuracio
    input  int      i_dbgTick,        // Numero de tick
    input  logic    i_dbgOk,          // Indicador d'iInstruccio executada
    input  InstAddr i_dbgPc,          // Adressa de la instruccio
    input  Inst     i_dbgInst,        // Instruccio
    input  RegAddr  i_dbgRegWrAddr,   // Registre per escriure
    input  logic    i_dbgRegWrEnable, // Autoritzacio d'escriptura en registre
    input  Data     i_dbgRegWrData,
    input  DataAddr i_dbgMemWrAddr,
    input  logic    i_dbgMemWrEnable,
    input  Data     i_dbgMemWrData,

    // Senyals de sortidade depuracio
    output int      o_dbgTick,        // Numero de tick
    output logic    o_dbgOk,          // Indicador d'instruccio executada
    output InstAddr o_dbgPc,          // Adressa de la instruccio
    output Inst     o_dbgInst,        // Instruccio
    output RegAddr  o_dbgRegWrAddr,   // Registre per escriure
    output logic    o_dbgRegWrEnable, // Autoritzacio d'escriptura en registre
    output Data     o_dbgRegWrData,
    output DataAddr o_dbgMemWrAddr,
    output logic    o_dbgMemWrEnable,
    output Data     o_dbgMemWrData,
`endif


    // Senyals d'entrada al pipeline
    input  RegAddr     i_regWrAddr,      // Registre per escriure
    input  logic       i_regWrEnable,    // Autoritzacio per escriure
    input  Data        i_regWrData,      // Dades per escriure

    // Senyal de sortida del pipeline
    //
    output RegAddr     o_regWrAddr,
    output logic       o_regWrEnable,
    output Data        o_regWrData);


    always_ff @(posedge i_clock) begin
        o_regWrAddr      <= i_reset ? {$size(RegAddr){1'b0}} : i_regWrAddr;
        o_regWrEnable    <= i_reset ? 1'b0                   : (i_flush ? 1'b0 : i_regWrEnable);
        o_regWrData      <= i_reset ? {$size(Data){1'b0}}    : i_regWrData;
`ifdef DEBUG
        o_dbgTick        <= i_dbgTick;
        o_dbgOk          <= (i_reset | i_flush) ? 1'b0 : i_dbgOk;
        o_dbgPc          <= i_dbgPc;
        o_dbgInst        <= i_dbgInst;
        o_dbgRegWrAddr   <= i_dbgRegWrAddr;
        o_dbgRegWrEnable <= i_dbgRegWrEnable;
        o_dbgRegWrData   <= i_dbgRegWrData;
        o_dbgMemWrAddr   <= i_dbgMemWrAddr;
        o_dbgMemWrEnable <= i_dbgMemWrEnable;
        o_dbgMemWrData   <= i_dbgMemWrData;
`endif
    end

endmodule
