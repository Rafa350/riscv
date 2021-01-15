`include "RV.svh"


module PipelineMEMWB
    import Types::*;
(
    // Senyals de control
    input  logic      i_clock,          // Clock
    input  logic      i_reset,          // Reset
    input  logic      i_flush,          // Retorna l'estat NOP

`ifdef DEBUG
    // Senyals d'entrada de depuracio
    input  int        i_dbgTick,        // Numero de tick
    input  logic      i_dbgOk,          // Indicador d'iInstruccio executada
    input  InstAddr   i_dbgPc,          // Adressa de la instruccio
    input  Inst       i_dbgInst,        // Instruccio
    input  RegAddr    i_dbgRegWrAddr,   // Registre per escriure
    input  logic      i_dbgRegWrEnable, // Autoritzacio d'escriptura en registre
    input  Data       i_dbgRegWrData,
    input  DataAddr   i_dbgMemWrAddr,
    input  logic      i_dbgMemWrEnable,
    input  Data       i_dbgMemWrData,
    input  DataAccess i_dbgMemAccess,

    // Senyals de sortidade depuracio
    output int        o_dbgTick,        // Numero de tick
    output logic      o_dbgOk,          // Indicador d'instruccio executada
    output InstAddr   o_dbgPc,          // Adressa de la instruccio
    output Inst       o_dbgInst,        // Instruccio
    output RegAddr    o_dbgRegWrAddr,   // Registre per escriure
    output logic      o_dbgRegWrEnable, // Autoritzacio d'escriptura en registre
    output Data       o_dbgRegWrData,
    output DataAddr   o_dbgMemWrAddr,
    output logic      o_dbgMemWrEnable,
    output Data       o_dbgMemWrData,
    output DataAccess o_dbgMemAccess,
`endif


    // Senyals d'entrada al pipeline
    input  RegAddr     i_regWrAddr,    // Registre per escriure
    input  logic       i_regWrEnable,  // Autoritzacio per escriure
    input  Data        i_regWrData,    // Dades per escriure

    // Senyal de sortida del pipeline
    //
    output RegAddr     o_regWrAddr,
    output logic       o_regWrEnable,
    output Data        o_regWrData);

    always_ff @(posedge i_clock)
        case ({i_reset, i_flush})
            2'b10, // RESET
            2'b11, // RESET
            2'b01: // FLUSH
                begin
                    o_regWrAddr   <= RegAddr'(0);
                    o_regWrEnable <= 1'b0;
                    o_regWrData   <= Data'(0);
                end

            2'b00: // NORMAL
                begin
                    o_regWrAddr   <= i_regWrAddr;
                    o_regWrEnable <= i_regWrEnable;
                    o_regWrData   <= i_regWrData;
                end
        endcase


`ifdef DEBUG
    always_ff @(posedge i_clock)
        case ({i_reset, i_flush})
            2'b10, // RESET
            2'b11, // RESET
            2'b01: // FLUSH
                begin
                    o_dbgTick        <= i_flush ? i_dbgTick : 0;
                    o_dbgOk          <= 1'b0;
                    o_dbgPc          <= InstAddr'(0);
                    o_dbgInst        <= Inst'(0);
                    o_dbgRegWrAddr   <= RegAddr'(0);
                    o_dbgRegWrEnable <= 1'b0;
                    o_dbgRegWrData   <= Data'(0);
                    o_dbgMemWrAddr   <= DataAddr'(0);
                    o_dbgMemWrEnable <= 1'b0;
                    o_dbgMemWrData   <= Data'(0);
                    o_dbgMemAccess   <= DataAccess'(0);
                end

            2'b00: // NORMAL
                begin
                    o_dbgTick        <= i_dbgTick;
                    o_dbgOk          <= i_dbgOk;
                    o_dbgPc          <= i_dbgPc;
                    o_dbgInst        <= i_dbgInst;
                    o_dbgRegWrAddr   <= i_dbgRegWrAddr;
                    o_dbgRegWrEnable <= i_dbgRegWrEnable;
                    o_dbgRegWrData   <= i_dbgRegWrData;
                    o_dbgMemWrAddr   <= i_dbgMemWrAddr;
                    o_dbgMemWrEnable <= i_dbgMemWrEnable;
                    o_dbgMemWrData   <= i_dbgMemWrData;
                    o_dbgMemAccess   <= i_dbgMemAccess;
                end
        endcase
`endif

endmodule
