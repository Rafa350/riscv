module StageMEM
    import Types::*;
(
    // Senyals de control
    input  logic      i_clock,        // Clock
    input  logic      i_reset,        // Reset

    // Interficie amb la memoria de dades
    DataBus.master    dataBus,        // Bus de la memoria de dades

    // Senyals operatives del stage
    input  logic      i_isValid,      // Indica operacio valida
    input  Data       i_dataR,        // Dades del resultst
    input  Data       i_dataB,        // Dades per escriure

    input  logic      i_memWrEnable,  // Habilita escriptura en memoria
    input  logic      i_memRdEnable,  // Habilita la lectura de la memoria
    input  DataAccess i_memAccess,    // Tamany d'acces a la memori
    input  logic      i_memUnsigned,  // Lectura de memoria sense signe

    input  WrDataSel  i_regWrDataSel, // Seleccio de dades per escriure en el registre
    output logic      o_hazard,       // Indica hazard
    output Data       o_regWrData);   // Dades per escriure en el registre


    assign o_hazard = 1'b0;


    // ------------------------------------------------------------------------
    // Interface amb la memoria de dades.
    // ------------------------------------------------------------------------

    Data  memAdapter_rdData;
    logic memAdapter_alignError;
    logic memAdapter_busy;

    DataMemoryAdapter
    memAdapter (
        .i_clock      (i_clock),
        .i_reset      (i_reset),
        .i_addr       (i_dataR[$size(DataAddr)-1:0]),
        .i_unsigned   (i_memUnsigned),
        .i_access     (i_memAccess),
        .i_wrEnable   (i_memWrEnable & i_isValid),
        .i_rdEnable   (i_memRdEnable & i_isValid),
        .i_wrData     (i_dataB),
        .o_rdData     (memAdapter_rdData),
        .o_busy       (memAdapter_busy),
        .o_alignError (memAdapter_alignError),
        .bus          (dataBus));


    // ------------------------------------------------------------------------
    // Selecciona les dades per escriure en el registre de destinacio en
    // funcio de la senyal i_regWrDataSel
    // ------------------------------------------------------------------------

    Mux2To1 #(
        .WIDTH ($size(Data)))
    regWrDataSelector (
        .i_select (i_regWrDataSel),
        .i_input0 (i_dataR),
        .i_input1 (memAdapter_rdData),
        .o_output (o_regWrData));


endmodule
