`include "RV.svh"


module StageWB
    import Types::*;
(
    RegisterBus.masterWriter regBus,         // Bus d'acces als registres per escriptura

    input  logic             i_isValid,      // Indica operacio valida
    input  Data              i_regWrData,    // Dades per escriure en el registre
    input  RegAddr           i_regWrAddr,    // Adresa d'escriptura del registre
    input  logic             i_regWrEnable); // Habilita l'escriptuira en el registre

    assign regBus.wrAddr = i_regWrAddr;
    assign regBus.wrData = i_regWrData;
    assign regBus.wr     = i_regWrEnable & i_isValid;

endmodule
