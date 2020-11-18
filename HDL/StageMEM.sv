module StageMEM 
#(
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 32,
    parameter PC_WIDTH   = 32,
    parameter REG_WIDTH  = 5)
(
    input  logic                  i_Clock,
    input  logic                  i_Reset,
    
    input  logic [DATA_WIDTH-1:0] i_MemRdData,
    output logic [DATA_WIDTH-1:0] o_MemWrData,
    output logic [ADDR_WIDTH-1:0] o_MemAddr,
    output logic                  o_MemWrEnable,
    
    input  logic [DATA_WIDTH-1:0] i_Result,
    input  logic [DATA_WIDTH-1:0] i_MemWrData,

    input  logic                  i_MemWrEnable,

    input  logic [1:0]            i_RegWrDataSel,   
    output logic [DATA_WIDTH-1:0] o_RegWrData);


    // ------------------------------------------------------------------------
    // Interface amb la memoria de dades.
    // ------------------------------------------------------------------------
    
    assign o_MemAddr     = i_Result[ADDR_WIDTH-1:0];
    assign o_MemWrEnable = i_MemWrEnable;
    assign o_MemWrData   = i_MemWrData;
    
    
    // ------------------------------------------------------------------------
    // Selecciona les dades de sortida.
    // ------------------------------------------------------------------------
    
    Mux4To1 #(
        .WIDTH (DATA_WIDTH))
    RegWrDataSelector (
        .i_Select (i_RegWrDataSel),  // Seleccio
        .i_Input0 (i_Result),        // El resultat de la ALU
        .i_Input1 (i_MemRdData),     // Dades de la memoria
        .i_Input2 (0),
        .i_Input3 (0),
        .o_Output (o_RegWrData));

endmodule
