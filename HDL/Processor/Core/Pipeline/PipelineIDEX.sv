module PipelineIDEX
    import ProcessorDefs::*,
           CoreDefs::*;
(
    // Senyals de control
    input  logic       i_clock,        // Clock
    input  logic       i_reset,        // Reset
    input  logic       i_stall,        // Retorna el mateix estat. Te prioritat sobre flush
    input  logic       i_flush,        // Retorna l'estat NOP

    // Senyals d'entrada al pipeline
    input  logic       i_isValid,      // Indica operacio valida
    input  InstAddr    i_pc,           // PC
    input  Data        i_instIMM,      // Valor IMM de la instruccio
    input  CSRAddr     i_instCSR,      // Valor CSR de la instruccio
    input  Data        i_dataRS1,      // Valor del registre RS1
    input  Data        i_dataRS2,      // Valor del registre RS2
    input  GPRAddr     i_regWrAddr,    // Registre per escriure
    input  logic       i_regWrEnable,  // Habilita l'escriptura en el registres
    input  WrDataSel   i_regWrDataSel, // Seleccio de dades per escriure en els registre
    input  logic       i_memWrEnable,  // Habilita la escriptura en memoria
    input  logic       i_memRdEnable,  // Habilida el lecturad e la memoria
    input  DataAccess  i_memAccess,    // Tamany del acces a la memoria
    input  logic       i_memUnsigned,  // Lectura de memoria sense signe
    input  DataASel    i_operandASel,  // Seleccio de l'operand A
    input  DataBSel    i_operandBSel,  // Seleccio de l'operand B
    input  ResultSel   i_resultSel,    // Seleccio del resultat
    input  AluOp       i_aluControl,   // Operacio en la unitat ALU
    input  MduOp       i_mduControl,   // Operacio en la unitat MDU
    input  CsrOp       i_csrControl,   // Operacio en la unitat CSR

    // Senyals de sortida del pipeline
    output logic       o_isValid,      // Indica operacio valida
    output InstAddr    o_pc,
    output Data        o_instIMM,      // Valor IMM de la instruccio
    output CSRAddr     o_instCSR,      // Valor CSR de la instruccio
    output Data        o_dataRS1,
    output Data        o_dataRS2,
    output GPRAddr     o_regWrAddr,
    output logic       o_regWrEnable,
    output WrDataSel   o_regWrDataSel,
    output logic       o_memWrEnable,  // Habilita la escriptura en memoria
    output logic       o_memRdEnable,  // Habilita la lectura de la memoria
    output DataAccess  o_memAccess,    // Tamany del acces la memoria
    output logic       o_memUnsigned,  // Lectura de memoria sense signe
    output DataASel    o_operandASel,
    output DataBSel    o_operandBSel,
    output ResultSel   o_resultSel,
    output AluOp       o_aluControl,
    output MduOp       o_mduControl,
    output CsrOp       o_csrControl);


    always_ff @(posedge i_clock)
        casez ({i_reset, i_stall, i_flush})
            3'b1??, // RESET
            3'b001: // FLUSH
                o_isValid <= 1'b0;

            3'b01?: // STALL
                ;

            3'b000: // NORMAL
                begin
                    o_isValid      <= i_isValid;
                    o_pc           <= i_pc;
                    o_instIMM      <= i_instIMM;
                    o_instCSR      <= i_instCSR;
                    o_dataRS1      <= i_dataRS1;
                    o_dataRS2      <= i_dataRS2;
                    o_regWrAddr    <= i_regWrAddr;
                    o_regWrEnable  <= i_regWrEnable;
                    o_regWrDataSel <= i_regWrDataSel;
                    o_memWrEnable  <= i_memWrEnable;
                    o_memRdEnable  <= i_memRdEnable;
                    o_memAccess    <= i_memAccess;
                    o_memUnsigned  <= i_memUnsigned;
                    o_aluControl   <= i_aluControl;
                    o_mduControl   <= i_mduControl;
                    o_csrControl   <= i_csrControl;
                    o_operandASel  <= i_operandASel;
                    o_operandBSel  <= i_operandBSel;
                    o_resultSel    <= i_resultSel;
                end
        endcase

endmodule