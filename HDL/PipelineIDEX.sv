module PipelineIDEX #(
    parameter DATA_WIDTH = 32,
    parameter PC_WIDTH   = 32,
    parameter REG_WIDTH  = 5)
(
    // Senyals de control
    input  logic                  i_Clock,        // Clock
    input  logic                  i_Reset,        // Reset
     
    // Senyals d'entrada al pipeline
    input  logic [PC_WIDTH-1:0]   i_PC,           // PC
    input  logic [6:0]            i_InstOP,       // Instruccio OP
    input  logic [DATA_WIDTH-1:0] i_DataA,        // Operand A per la ALU
                                  i_DataB,        // Operand B per la ALU
    input  logic [REG_WIDTH-1:0]  i_RegWrAddr,    // Registre per escriure
    input  logic                  i_RegWrEnable,  // Habilita l'escriptura en el registres
    input  logic [1:0]            i_RegWrDataSel, // Seleccio de dades per escriure en els registre
    input  logic                  i_MemWrEnable,  // Habilita la escriptura en memoria
    input  logic [DATA_WIDTH-1:0] i_MemWrData,    // Dades per escriure en memoria
    input  logic [4:0]            i_AluControl,   // Control de la ALU
    
    // Senyals de sortida del pipeline
    output logic [PC_WIDTH-1:0]   o_PC,
    output logic [6:0]            o_InstOP,     
    output logic [DATA_WIDTH-1:0] o_DataA,
                                  o_DataB,
    output logic [REG_WIDTH-1:0]  o_RegWrAddr,
    output logic                  o_RegWrEnable,
    output logic [1:0]            o_RegWrDataSel,
    output logic                  o_MemWrEnable,
    output logic [DATA_WIDTH-1:0] o_MemWrData,
    output logic [4:0]            o_AluControl);
    
    
    always_ff @(posedge i_Clock) begin
        o_PC           <= i_Reset ? 32'b0 : i_PC;
        o_InstOP       <= i_Reset ?  7'b0 : i_InstOP;
        o_DataA        <= i_Reset ? 32'b0 : i_DataA;
        o_DataB        <= i_Reset ? 32'b0 : i_DataB;
        o_RegWrAddr    <= i_Reset ?  5'b0 : i_RegWrAddr;
        o_RegWrEnable  <= i_Reset ?  1'b0 : i_RegWrEnable;
        o_RegWrDataSel <= i_Reset ?  2'b0 : i_RegWrDataSel;
        o_MemWrEnable  <= i_Reset ?  1'b0 : i_MemWrEnable;
        o_MemWrData    <= i_Reset ? 32'b0 : i_MemWrData;
        o_AluControl   <= i_Reset ?  5'b0 : i_AluControl;
    end
    
    
endmodule