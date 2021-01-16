`include "RV.svh"


module PipelineEXMEM
    import Types::*;
(
    // Senyals de control
    input  logic       i_clock,        // Clock
    input  logic       i_reset,        // Reset
    input  logic       i_stall,        // Retorna el mateix estat. Te prioritat sobre flush
    input  logic       i_flush,        // Retorna l'estat NOP

`ifdef DEBUG
    // Senyals d'entrada de depuracio
    input  int         i_dbgTick,        // Numero de tick
    input  Inst        i_dbgInst,        // Instruccio
    input  RegAddr     i_dbgRegWrAddr,   // Registre per escriure
    input  logic       i_dbgRegWrEnable, // Autoritzacio d'escriptura en registre

    // Senyals de sortidade depuracio
    output int         o_dbgTick,        // Numero de tick
    output Inst        o_dbgInst,        // Instruccio
    output RegAddr     o_dbgRegWrAddr,   // Registre per escriure
    output logic       o_dbgRegWrEnable, // Autoritzacio d'escriptura en registre
`endif

    // Senyals d'entrada al pipeline
    input  logic       i_isValid,        // Indica operacio valida
    input  InstAddr    i_pc,             // Adressa de la instruccio
    input  Data        i_result,
    input  Data        i_dataB,
    input  logic       i_memWrEnable,    // Autoritza l'escriptura en la memoria
    input  logic       i_memRdEnable,    // Habilita la lectura de la memoria
    input  DataAccess  i_memAccess,      // Tamany del access a la memoria
    input  logic       i_memUnsigned,    // Lectura de memoria sense signe
    input  RegAddr     i_regWrAddr,
    input  logic       i_regWrEnable,    // Autoritza l'escriptura en els registres
    input  logic [1:0] i_regWrDataSel,

    // Senyals de sortida del pipeline
    output logic       o_isValid,        // Indica operacio valida
    output InstAddr    o_pc,
    output Data        o_result,
    output Data        o_dataB,
    output logic       o_memWrEnable,  // Autoritza l'escriptura en memoria
    output logic       o_memRdEnable,  // Autoritza la lectura de la memoria
    output DataAccess  o_memAccess,    // Tamany del acces a la memoria
    output logic       o_memUnsigned,  // Lectura de memoria sense signe
    output RegAddr     o_regWrAddr,
    output logic       o_regWrEnable,
    output logic [1:0] o_regWrDataSel);


    always_ff @(posedge i_clock)
        casez ({i_reset, i_stall, i_flush})
            3'b1??, // RESET
            3'b001: // FLUSH
                o_isValid <= 1'b0;

            3'b01?: // STALL
                ;

            3'b000: // NORMAL
                begin
                    o_isValid      <= i_isValid;
                    o_pc           <= i_pc;
                    o_result       <= i_result;
                    o_dataB        <= i_dataB;
                    o_memWrEnable  <= i_memWrEnable;
                    o_memRdEnable  <= i_memRdEnable;
                    o_memAccess    <= i_memAccess;
                    o_memUnsigned  <= i_memUnsigned;
                    o_regWrAddr    <= i_regWrAddr;
                    o_regWrEnable  <= i_regWrEnable;
                    o_regWrDataSel <= i_regWrDataSel;
                end
        endcase

`ifdef DEBUG
    always_ff @(posedge i_clock)
        casez ({i_reset, i_stall, i_flush})
            3'b1??, // RESET
            3'b001: // FLUSH
                begin
                    o_dbgTick        <= i_flush ? i_dbgTick : 0;
                    o_dbgInst        <= Inst'(0);
                    o_dbgRegWrAddr   <= RegAddr'(0);
                    o_dbgRegWrEnable <= 1'b0;
                end

            3'b01?: // STALL
                ;

            3'b000: // NORMAL
                begin
                    o_dbgTick        <= i_dbgTick;
                    o_dbgInst        <= i_dbgInst;
                    o_dbgRegWrAddr   <= i_dbgRegWrAddr;
                    o_dbgRegWrEnable <= i_dbgRegWrEnable;
                end
        endcase
`endif


endmodule
