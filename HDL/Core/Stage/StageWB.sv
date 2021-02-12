module StageWB
    import Types::*;
(
    // Senyals de control i sincronitzacio
    input  logic   i_clock,       // Clock
    input  logic   i_reset,       // Reset

    // Interficie amb el bloc de registres
    output GPRAddr o_reg_waddr,
    output Data    o_reg_wdata,
    output logic   o_reg_we,

    // Senyals operatives del stage
    input  logic   i_isValid,     // Indica operacio valida
    input  Data    i_regWrData,   // Dades per escriure en el registre
    input  GPRAddr i_regWrAddr,   // Adresa d'escriptura del registre
    input  logic   i_regWrEnable, // Habilita l'escriptuira en el registre
    output logic   o_hazard,      // Indica hazard
    output logic   o_instRet);    // Indica instruccio retirada


    assign o_reg_waddr = i_regWrAddr;
    assign o_reg_wdata = i_regWrData;
    assign o_reg_we    = i_regWrEnable & i_isValid;
    assign o_hazard    = 1'b0;
    assign o_instRet   = i_isValid;


endmodule
