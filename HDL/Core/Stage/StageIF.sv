module StageIF
    import Config::*, Types::*;
(
    // Senyals de control i sincronitzacio
    input  logic        i_clock,           // Clock
    input  logic        i_reset,           // Reset

    // Interficie amb la memoria/cache d'instruccions
    InstCoreBus.master  instBus,           // Bus de la memoria d'instruccions

    // Senyals del stage MEM per la gestio dels hazards
    input  logic        i_MEM_isValid,     // Indica operacio valida en MEM
    input  logic        i_MEM_memRdEnable, // Indica operacio de lectura en MEM
    input  logic        i_MEM_memWrEnable, // Indica operacio d'escriptura en MEM

    // Senyals de control d'execucio
    input  InstAddr     i_pcNext,          // El nou valor del PC
    output logic        o_hazard,          // Indica hazard
    output Inst         o_inst,            // Instruccio
    output logic        o_instCompressed,  // Indica que la instruccio es comprimida
    output InstAddr     o_pc);             // El valor del PC


    assign o_pc         = i_pcNext;
    assign instBus.addr = o_pc;
    assign instBus.re   = 1'b1;


    // ------------------------------------------------------------------------
    // Detecta els hazards deguts a accessos a memoria simultanis amb
    // la lectura e la instruccio
    // ------------------------------------------------------------------------

    generate
        if (RV_ICACHE_ON)
            assign o_hazard = instBus.busy;
        else begin
            StageIF_HazardDetector
            hazardDetector(
                .i_MEM_isValid     (i_MEM_isValid),
                .i_MEM_memRdEnable (i_MEM_memRdEnable),
                .i_MEM_memWrEnable (i_MEM_memWrEnable),
                .o_hazard          (o_hazard)); // Indica que s'ha detectat un hazard
        end
    endgenerate


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
