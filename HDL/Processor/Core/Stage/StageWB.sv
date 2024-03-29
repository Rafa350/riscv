module StageWB
    import
        ProcessorDefs::*;
(
    // Senyals de control i sincronitzacio
    input  logic   i_clock,       // Clock
    input  logic   i_reset,       // Reset

    // Interficie amb GPR
    output GPRAddr o_reg_waddr,
    output Data    o_reg_wdata,
    output logic   o_reg_we,

    // Senyals operatives del stage
    input  logic   i_isValid,     // Indica operacio valida
    input  Data    i_regWrData,   // Dades per escriure en el registre
    input  GPRAddr i_regWrAddr,   // Adresa d'escriptura del registre
    input  logic   i_regWrEnable, // Habilita l'escriptuira en el registre
    output logic   o_hazard,      // Indica hazard
    output logic   o_evInstRet);  // Indica instruccio retirada


    assign o_reg_waddr = i_regWrAddr;
    assign o_reg_wdata = i_regWrData;
    assign o_reg_we    = i_regWrEnable & i_isValid;


    // -------------------------------------------------------------------
    // Deteccio de hazards
    // -------------------------------------------------------------------

    assign o_hazard    = 1'b0;


    // -------------------------------------------------------------------
    // Genera events pels contadors de rendiment
    // -------------------------------------------------------------------

    assign o_evInstRet = i_isValid;


endmodule
