module StageMEM #(
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 32,
    parameter REG_WIDTH  = 5)
(
    input  logic                  i_Clock,
    input  logic                  i_Reset,
    
    input  logic [DATA_WIDTH-1:0] i_MemRdData,
    output logic [DATA_WIDTH-1:0] o_MemWrData,
    output logic [ADDR_WIDTH-1:0] o_MemAddr,
    output logic                  o_MemWrEnable,
    
    input  logic [6:0]            i_InstOP,
    input  logic [DATA_WIDTH-1:0] i_Result,
    input  logic [DATA_WIDTH-1:0] i_MemWrData,

    input  logic [REG_WIDTH-1:0]  i_RegWrAddr,
    
    input  logic                  i_RegWrEnable,
    input  logic [1:0]            i_RegWrDataSel,
    input  logic                  i_MemWrEnable,
    
    output logic [DATA_WIDTH-1:0] o_RegWrData,
    output logic [REG_WIDTH-1:0]  o_RegWrAddr,
    output logic                  o_RegWrEnable);


    // ------------------------------------------------------------------------
    // Interface amb la memoria de dades.
    // ------------------------------------------------------------------------
    
    assign o_MemAddr     = i_Result;
    assign o_MemWrEnable = i_MemWrEnable;
    assign o_MemWrData   = i_MemWrData;
    
    
    // ------------------------------------------------------------------------
    // Selecciona les dades de sortida.
    // ------------------------------------------------------------------------
    
    logic [DATA_WIDTH-1:0] RegWrDataSelector_Output;
    
    Mux4To1 #(
        .WIDTH (DATA_WIDTH))
    RegWrDataSelector (
        .i_Select (i_RegWrDataSel),  // Seleccio
        .i_Input0 (i_Result),        // El resultat de la ALU
        .i_Input1 (i_MemRdData),     // Dades de la memoria
        .i_Input2 (0),
        .i_Input3 (0),
        .o_Output (RegWrDataSelector_Output));
    
       
    always_comb begin
        o_RegWrData   = RegWrDataSelector_Output;
        o_RegWrAddr   = i_RegWrAddr;
        o_RegWrEnable = i_RegWrEnable;
    end

endmodule
