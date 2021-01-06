`include "RV.svh"


module PipelineIDEX
    import Types::*;
(
    // Senyals de control
    input  logic       i_clock,          // Clock
    input  logic       i_reset,          // Reset
    input  logic       i_flush,          // Descarda les accions d'escriptura

`ifdef DEBUG
    // Senyals d'entrada de depuracio
    input  int         i_dbgTick,        // Numero de tick
    input  logic       i_dbgOk,          // Indicador d'iInstruccio executada
    input  Inst        i_dbgInst,        // Instruccio
    input  RegAddr     i_dbgRegWrAddr,   // Registre per escriure
    input  logic       i_dbgRegWrEnable, // Autoritzacio d'escriptura en registre

    // Senyals de sortidade depuracio
    output int         o_dbgTick,        // Numero de tick
    output logic       o_dbgOk,          // Indicador d'instruccio executada
    output Inst        o_dbgInst,        // Instruccio
    output RegAddr     o_dbgRegWrAddr,   // Registre per escriure
    output logic       o_dbgRegWrEnable, // Autoritzacio d'escriptura en registre
`endif

    // Senyals d'entrada al pipeline
    input  InstAddr    i_pc,             // PC
    input  Data        i_instIMM,        // Valor inmediat de la instruccio
    input  Data        i_dataA,          // Operand A per la ALU
    input  Data        i_dataB,          // Operand B per la ALU
    input  RegAddr     i_regWrAddr,      // Registre per escriure
    input  logic       i_regWrEnable,    // Habilita l'escriptura en el registres
    input  logic [1:0] i_regWrDataSel,   // Seleccio de dades per escriure en els registre
    input  logic       i_memWrEnable,    // Habilita la escriptura en memoria
    input  logic       i_memRdEnable,    // Habilida el lecturad e la memoria
    input  DataAccess  i_memAccess,      // Tamany del acces a la memoria
    input  logic       i_memUnsigned,    // Lectura de memoria sense signe
    input  logic [1:0] i_operandASel,    // Seleccio de l'operasnd A
    input  logic [1:0] i_operandBSel,    // Seleccio de l'operand B
    input  AluOp       i_aluControl,     // Control de la ALU

    // Senyals de sortida del pipeline
    output InstAddr    o_pc,
    output Data        o_instIMM,        // Valor inmediat de la instruccio
    output Data        o_dataA,
    output Data        o_dataB,
    output RegAddr     o_regWrAddr,
    output logic       o_regWrEnable,
    output logic [1:0] o_regWrDataSel,
    output logic       o_memWrEnable,    // Habilita la escriptura en memoria
    output logic       o_memRdEnable,    // Habilita la lectura de la memoria
    output DataAccess  o_memAccess,      // Tamany del acces la memoria
    output logic       o_memUnsigned,    // Lectura de memoria sense signe
    output logic [1:0] o_operandASel,
    output logic [1:0] o_operandBSel,
    output AluOp       o_aluControl);


    always_ff @(posedge i_clock) begin
        o_pc             <= i_reset ? {$size(InstAddr){1'b0}} : i_pc;
        o_instIMM        <= i_reset ? {$size(Data){1'b0}}     : i_instIMM;
        o_dataA          <= i_reset ? {$size(Data){1'b0}}     : i_dataA;
        o_dataB          <= i_reset ? {$size(Data){1'b0}}     : i_dataB;
        o_regWrAddr      <= i_reset ? {$size(RegAddr){1'b0}}  : i_regWrAddr;
        o_regWrEnable    <= i_reset ? 1'b0                    : (i_flush ? 1'b0 : i_regWrEnable);
        o_regWrDataSel   <= i_reset ? 2'b0                    : i_regWrDataSel;
        o_memWrEnable    <= i_reset ? 1'b0                    : (i_flush ? 1'b0 : i_memWrEnable);
        o_memRdEnable    <= i_reset ? 1'b0                    : (i_flush ? 1'b0 : i_memRdEnable);
        o_memAccess      <= i_reset ? DataAccess_Word         : i_memAccess;
        o_memUnsigned    <= i_reset ? 1'b0                    : i_memUnsigned;
        o_aluControl     <= i_reset ? AluOp_Unknown           : i_aluControl;
        o_operandASel    <= i_reset ? 2'b0                    : i_operandASel;
        o_operandBSel    <= i_reset ? 2'b0                    : i_operandBSel;
`ifdef DEBUG
        o_dbgTick        <= i_dbgTick;
        o_dbgOk          <= (i_reset | i_flush) ? 1'b0 : i_dbgOk;
        o_dbgInst        <= i_dbgInst;
        o_dbgRegWrAddr   <= i_dbgRegWrAddr;
        o_dbgRegWrEnable <= i_dbgRegWrEnable;
`endif
    end


endmodule