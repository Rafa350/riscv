module StageIF
    import Config::*, Types::*;
(
    // Senyals de control i sincronitzacio
    input  logic    i_clock,           // Clock
    input  logic    i_reset,           // Reset

    // Interficie amb la memoria/cache d'instruccions
    InstBus.master instBus,           // Bus de la memoria d'instruccions

    // Senyals de control d'execucio
    input  InstAddr i_pcNext,          // El nou valor del PC
    output logic    o_hazard,          // Indica hazard
    output Inst     o_inst,            // Instruccio
    output logic    o_instCompressed,  // Indica que la instruccio es comprimida
    output InstAddr o_pc);             // El valor del PC


    assign o_pc         = i_pcNext;
    assign instBus.addr = o_pc;
    assign instBus.re   = 1'b1;


    // ------------------------------------------------------------------------
    // Detecta els hazards deguts als accessos a la memoria
    // ------------------------------------------------------------------------

    assign o_hazard = instBus.busy;


    // ------------------------------------------------------------------------
    // Obte la instruccio de la memoria, i si cal la expandeix.
    // ------------------------------------------------------------------------

    generate
        if (RV_EXT_C == 1) begin
            InstExpander
            exp (
                .i_inst         (instBus.inst),
                .o_inst         (o_inst),
                .o_isCompressed (o_instCompressed));
        end
        else begin
            assign o_inst           = instBus.inst;
            assign o_instCompressed = 1'b0;
        end
    endgenerate


endmodule
