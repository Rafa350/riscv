module PipelineIDEX
#(
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 32,
    parameter PC_WIDTH   = 32,
    parameter REG_WIDTH  = 5)
(
    // Senyals de control
    input  logic                  i_Clock,        // Clock
    input  logic                  i_Reset,        // Reset

     // Senyals de depuracio
    input  logic [2:0]            i_DbgTag,       // Etiqueta de depuracio
    output logic [2:0]            o_DbgTag,

    // Senyals de control del pipeline
    input  logic                  i_Flush,
    input  logic                  i_Stall,

    // Senyals d'entrada al pipeline
    input  logic [PC_WIDTH-1:0]   i_PC,           // PC
    input  logic [6:0]            i_InstOP,       // Instruccio OP
    input  logic [REG_WIDTH-1:0]  i_InstRS1,      // Instruccio RS1
    input  logic [REG_WIDTH-1:0]  i_InstRS2,      // Instruccio RS2
    input  logic [DATA_WIDTH-1:0] i_InstIMM,      // Valor inmediat de la instruccio
    input  logic [DATA_WIDTH-1:0] i_DataA,        // Operand A per la ALU
                                  i_DataB,        // Operand B per la ALU
    input  logic [REG_WIDTH-1:0]  i_RegWrAddr,    // Registre per escriure
    input  logic                  i_RegWrEnable,  // Habilita l'escriptura en el registres
    input  logic [1:0]            i_RegWrDataSel, // Seleccio de dades per escriure en els registre
    input  logic                  i_MemWrEnable,  // Habilita la escriptura en memoria
    input  logic                  i_OperandASel,
    input  logic                  i_OperandBSel,
    input  logic [4:0]            i_AluControl,   // Control de la ALU

    // Senyals de sortida del pipeline
    output logic [PC_WIDTH-1:0]   o_PC,
    output logic [6:0]            o_InstOP,
    output logic [REG_WIDTH-1:0]  o_InstRS1,      // Instruccio RS1
    output logic [REG_WIDTH-1:0]  o_InstRS2,      // Instruccio RS2
    output logic [DATA_WIDTH-1:0] o_InstIMM,      // Valor inmediat de la instruccio
    output logic [DATA_WIDTH-1:0] o_DataA,
                                  o_DataB,
    output logic [REG_WIDTH-1:0]  o_RegWrAddr,
    output logic                  o_RegWrEnable,
    output logic [1:0]            o_RegWrDataSel,
    output logic                  o_MemWrEnable,
    output logic                  o_OperandASel,
    output logic                  o_OperandBSel,
    output logic [4:0]            o_AluControl);


    always_ff @(posedge i_Clock) begin
        o_PC           <= i_Reset ? {PC_WIDTH{1'b0}}   : (i_Stall ?  o_PC           : i_PC);
        o_InstOP       <= i_Reset ? 7'b0               : (i_Stall ?  o_InstOP       : i_InstOP);
        o_InstRS1      <= i_Reset ? {REG_WIDTH{1'b0}}  : (i_Stall ?  o_InstRS1      : i_InstRS1);
        o_InstRS2      <= i_Reset ? {REG_WIDTH{1'b0}}  : (i_Stall ?  o_InstRS2      : i_InstRS2);
        o_InstIMM      <= i_Reset ? {DATA_WIDTH{1'b0}} : (i_Stall ?  o_InstIMM      : i_InstIMM);
        o_DataA        <= i_Reset ? {DATA_WIDTH{1'b0}} : (i_Stall ?  o_DataA        : i_DataA);
        o_DataB        <= i_Reset ? {DATA_WIDTH{1'b0}} : (i_Stall ?  o_DataB        : i_DataB);
        o_RegWrAddr    <= i_Reset ? {REG_WIDTH{1'b0}}  : (i_Stall ?  o_RegWrAddr    : i_RegWrAddr);
        o_RegWrEnable  <= i_Reset ? 1'b0               : (i_Stall ?  o_RegWrEnable  : i_RegWrEnable);
        o_RegWrDataSel <= i_Reset ? 2'b0               : (i_Stall ?  o_RegWrDataSel : i_RegWrDataSel);
        o_MemWrEnable  <= i_Reset ? 1'b0               : (i_Stall ?  o_MemWrEnable  : i_MemWrEnable);
        o_AluControl   <= i_Reset ? 5'b0               : (i_Stall ?  o_AluControl   : i_AluControl);
        o_OperandASel  <= i_Reset ? 1'b0               : (i_Stall ?  o_OperandASel  : i_OperandASel);
        o_OperandBSel  <= i_Reset ? 1'b0               : (i_Stall ?  o_OperandBSel  : i_OperandBSel);
        o_DbgTag       <= i_Reset ? 3'b0               : i_DbgTag;
    end


endmodule