module DebugPipelineMEMWB (
    // Senyals de control
    input  logic                   i_clock,          // Clock
    input  logic                   i_reset,          // Reset
    input  logic                   i_flush,          // Retorna l'estat NOP

    // Senyals d'entrada del pipeline
    input  int                     i_dbgTick,        // Numero de tick
    input  ProcessorDefs::InstAddr i_dbgPc,          // Adressa de la instruccio
    input  ProcessorDefs::Inst     i_dbgInst,        // Instruccio
    input  ProcessorDefs::DataAddr i_dbgMemWrAddr,
    input  logic                   i_dbgMemWrEnable,
    input  ProcessorDefs::Data     i_dbgMemWrData,
    input  CoreDefs::DataAccess    i_dbgMemAccess,

    // Senyals de sortida del pipeline
    output int                     o_dbgTick,        // Numero de tick
    output ProcessorDefs::InstAddr o_dbgPc,          // Adressa de la instruccio
    output ProcessorDefs::Inst     o_dbgInst,        // Instruccio
    output ProcessorDefs::DataAddr o_dbgMemWrAddr,
    output logic                   o_dbgMemWrEnable,
    output ProcessorDefs::Data     o_dbgMemWrData,
    output CoreDefs::DataAccess    o_dbgMemAccess);


    always_ff @(posedge i_clock)
        casez ({i_reset, i_flush})
            2'b1?, // RESET
            2'b01: // FLUSH
                begin
                    o_dbgTick        <= i_flush ? i_dbgTick : 0;
                    o_dbgPc          <= ProcessorDefs::InstAddr'(0);
                    o_dbgInst        <= ProcessorDefs::Inst'(0);
                    o_dbgMemWrAddr   <= ProcessorDefs::DataAddr'(0);
                    o_dbgMemWrEnable <= 1'b0;
                    o_dbgMemWrData   <= ProcessorDefs::Data'(0);
                    o_dbgMemAccess   <= CoreDefs::DataAccess'(0);
                end

            2'b00: // NORMAL
                begin
                    o_dbgTick        <= i_dbgTick;
                    o_dbgPc          <= i_dbgPc;
                    o_dbgInst        <= i_dbgInst;
                    o_dbgMemWrAddr   <= i_dbgMemWrAddr;
                    o_dbgMemWrEnable <= i_dbgMemWrEnable;
                    o_dbgMemWrData   <= i_dbgMemWrData;
                    o_dbgMemAccess   <= i_dbgMemAccess;
                end
        endcase

endmodule
