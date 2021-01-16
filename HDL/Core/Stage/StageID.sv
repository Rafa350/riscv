`include "RV.svh"


module StageID
    import Types::*;
(
    // Senyals de control i sincronitzacio
    input  logic             i_clock,           // Clock
    input  logic             i_reset,           // Reset

    // Interficie amb el bloc de registres
    RegisterBus.masterReader regBus,            // Bus d'acces als registres per lectura

    // Senyals del stage EX per la gestio dels hazards
    input  logic             i_EX_isValid,      // Indica operacio valida en EX
    input  RegAddr           i_EX_regWrAddr,    // Registre per escriure en EX
    input  logic             i_EX_regWrEnable,  // Habilita l'escriptura en el registre en EX
    input  logic [1:0]       i_EX_regWrDataSel, // Seleccio de dades en EX
    input  Data              i_EX_regWrData,    // Dades a escriure en el registre en EX
    input  logic             i_EX_memRdEnable,  // Habilita la lectura de memoria en EX

    // Senyals del stage MEM per la gestio dels hazards
    input  logic             i_MEM_isValid,     // Indica operacio valida en MEM
    input  RegAddr           i_MEM_regWrAddr,   // Registre per escriure en MEM
    input  logic             i_MEM_regWrEnable, // Habilita l'escriptura en MEM
    input  Data              i_MEM_regWrData,   // Dades a escriure en MEM
    input  logic             i_MEM_memRdEnable, // Habilita la lectura de memoria en MEM

    // Senyals del stage WB per la gestio dels hazards
    input  logic             i_WB_isValid,      // Indica operacio valida en WB
    input  RegAddr           i_WB_regWrAddr,    // Registre a escriure en WB
    input  logic             i_WB_regWrEnable,  // Autoritzacio d'escriptura del registre wn WB
    input  Data              i_WB_regWrData,    // El resultat a escriure en WB

    // Senyals operatives del stage
    input  Inst              i_inst,            // Instruccio
    input  logic             i_instCompressed,  // Indica que es una instruccio comprimida
    input  InstAddr          i_pc,              // Adressa de la instruccio
    output Data              o_instIMM,         // Valor inmediat de la instruccio
    output Data              o_dataA,           // Dades A (rs1)
    output Data              o_dataB,           // Dades B (rs2)
    output logic             o_hazard,          // Indica hazard
    output RegAddr           o_regWrAddr,       // Registre a escriure.
    output logic             o_regWrEnable,     // Habilita l'escriptura del registre
    output logic             o_memWrEnable,     // Habilita l'escritura en memoria
    output logic             o_memRdEnable,     // Habilita la lectura de la memoria
    output DataAccess        o_memAccess,       // Tamany d'acces a la memoria
    output logic             o_memUnsigned,     // Lectura de memoria sense signe
    output logic [1:0]       o_regWrDataSel,    // Seleccio de les dades per escriure en el registre (rd)
    output logic [1:0]       o_operandASel,     // Seleccio del valor A de la ALU
    output logic [1:0]       o_operandBSel,     // Seleccio del valor B de la ALU
    output AluOp             o_aluControl,      // Codi de control de la ALU
    output InstAddr          o_pcNext);         // Nou valor de PC


    // ------------------------------------------------------------------------
    // Decodificador d'instruccions.
    // Separa les instruccions en els seus components, calculant el valor
    // IMM de la instruccio en funcio del seu tipus. Tambe indica el tipus
    // d'instruccio.
    // ------------------------------------------------------------------------

    OpCode    dec_instOP;
    RegAddr   dec_instRS1;
    RegAddr   dec_instRS2;
    RegAddr   dec_instRD;
    Data      dec_instIMM;
    CSRegAddr dec_instCSR;
    logic     dec_isIllegal;
    logic     dec_isALU;
    logic     dec_isECALL;
    logic     dec_isEBREAK;
    logic     dec_isCSR;

    InstDecoder
    dec (
        .i_inst      (i_inst),
        .o_instOP    (dec_instOP),
        .o_instRS1   (dec_instRS1),
        .o_instRS2   (dec_instRS2),
        .o_instRD    (dec_instRD),
        .o_instIMM   (dec_instIMM),
        .o_instCSR   (dec_instCSR),
        .o_isIllegal (dec_isIllegal),
        .o_isALU     (dec_isALU),
        .o_isECALL   (dec_isECALL),
        .o_isEBREAK  (dec_isEBREAK),
        .o_isCSR     (dec_isCSR));


    // ------------------------------------------------------------------------
    // Controlador del datapath.
    // Genera les senyals de control de les rutes de dades.
    // ------------------------------------------------------------------------

    AluOp       dpCtrl_aluControl;   // Operacio de la ALU
    logic       dpCtrl_regWrEnable;  // Autoritza escriptura del regisres
    logic       dpCtrl_memWrEnable;  // Autoritza l'escritura en memoria
    logic       dpCtrl_memRdEnable;  // Autoritza la lectura de la memoria
    DataAccess  dpCtrl_memAccess;    // Tamany d'access a la memoria
    logic       dpCtrl_memUnsigned;  // Lectura de memoria sense signe
    logic       dpCtrl_cmpUnsigned;  // Comparacio sense signe
    logic [1:0] dpCtrl_pcNextSel;    // Selector del seguent valor del PC
    logic [1:0] dpCtrl_dataToRegSel; // Selector del les dades d'escriptura en el registre
    logic [1:0] dpCtrl_operandASel;  // Seleccio del operand A de la ALU
    logic [1:0] dpCtrl_operandBSel;  // Seleccio del operand B de la ALU

    DatapathController
    dpCtrl (
        .i_inst           (i_inst),                // La instruccio
        .i_isEqual        (brComp_isEqual),        // Indicador r1 == r2
        .i_isLessSigned   (brComp_isLessSigned),   // Indicador r1 < r2 amb signe
        .i_isLessUnsigned (brComp_isLessUnsigned), // Indicador r1 < r2 amb signe
        .o_memWrEnable    (dpCtrl_memWrEnable),
        .o_memAccess      (dpCtrl_memAccess),      // Tamany d'acces a la memoria
        .o_memUnsigned    (dpCtrl_memUnsigned),    // Lectura de memoria sense signe
        .o_memRdEnable    (dpCtrl_memRdEnable),
        .o_regWrEnable    (dpCtrl_regWrEnable),
        .o_regWrDataSel   (dpCtrl_dataToRegSel),
        .o_aluControl     (dpCtrl_aluControl),
        .o_operandASel    (dpCtrl_operandASel),
        .o_operandBSel    (dpCtrl_operandBSel),
        .o_pcNextSel      (dpCtrl_pcNextSel));


    // ------------------------------------------------------------------------
    // Detecta els hazards deguts a instruccions LOAD pendents
    // En aquest cas genera una senyal per controlador del stalls del pipeline
    // ------------------------------------------------------------------------

    StageID_HazardDetector
    hazardDetector (
        .i_instRS1         (dec_instRS1),
        .i_instRS2         (dec_instRS2),
        .i_EX_isValid      (i_EX_isValid),
        .i_EX_memRdEnable  (i_EX_memRdEnable),
        .i_EX_regAddr      (i_EX_regWrAddr),
        .i_MEM_isValid     (i_MEM_isValid),
        .i_MEM_memRdEnable (i_MEM_memRdEnable),
        .i_MEM_regAddr     (i_MEM_regWrAddr),
        .o_hazard          (o_hazard));          // Indica que s'ha detectat un hazard


    // ------------------------------------------------------------------------
    // Controlador de Forwarding. Selecciona el valor dels registres no
    // actualitzats, en les etapes posteriors del pipeline.
    // ------------------------------------------------------------------------

    logic [1:0] fwdCtrl_dataASel,
                fwdCtrl_dataBSel;

    StageID_ForwardController
    fwdCtrl(
        .i_instRS1         (dec_instRS1),
        .i_instRS2         (dec_instRS2),
        .i_EX_isValid      (i_EX_isValid),
        .i_EX_regWrAddr    (i_EX_regWrAddr),
        .i_EX_regWrEnable  (i_EX_regWrEnable),
        .i_EX_regWrDataSel (i_EX_regWrDataSel),
        .i_MEM_isValid     (i_MEM_isValid),
        .i_MEM_regWrAddr   (i_MEM_regWrAddr),
        .i_MEM_regWrEnable (i_MEM_regWrEnable),
        .i_WB_isValid      (i_WB_isValid),
        .i_WB_regWrAddr    (i_WB_regWrAddr),
        .i_WB_regWrEnable  (i_WB_regWrEnable),
        .o_dataASel        (fwdCtrl_dataASel),   // Obte l'origen de les dades A
        .o_dataBSel        (fwdCtrl_dataBSel));  // Obte l'origen de les dades B


    // -----------------------------------------------------------------------
    // Seleccio de les dades del registre o de les etapes posteriors.
    // -----------------------------------------------------------------------

    Data fwdDataASelector_output;
    Data fwdDataBSelector_output;

    Mux4To1 #(
        .WIDTH ($size(Data)))
    fwdDataASelector (
        .i_select (fwdCtrl_dataASel),
        .i_input0 (regs_dataA),
        .i_input1 (i_EX_regWrData),
        .i_input2 (i_MEM_regWrData),
        .i_input3 (i_WB_regWrData),
        .o_output (fwdDataASelector_output)); // Obte el valor de des dades A

    Mux4To1 #(
        .WIDTH ($size(Data)))
    fwdDataBSelector (
        .i_select (fwdCtrl_dataBSel),
        .i_input0 (regs_dataB),
        .i_input1 (i_EX_regWrData),
        .i_input2 (i_MEM_regWrData),
        .i_input3 (i_WB_regWrData),
        .o_output (fwdDataBSelector_output)); // Obte el valor de les dades B


    // ------------------------------------------------------------------------
    // Comparador per les instruccions de salt.
    // Permet identificas les condicions de salt abans d'executar
    // la instruccio, calculant l'adressa de salt de la seguent instruccio
    // en IF.
    // ------------------------------------------------------------------------
    //
    logic brComp_isEqual;        // Indica A == B
    logic brComp_isLessSigned;   // Indica A < B amb signe
    logic brComp_isLessUnsigned; // Indica A = B sense signe

    BranchComparer
    brComp(
        .i_dataA          (fwdDataASelector_output),
        .i_dataB          (fwdDataBSelector_output),
        .o_isEqual        (brComp_isEqual),
        .o_isLessSigned   (brComp_isLessSigned),
        .o_isLessUnsigned (brComp_isLessUnsigned));


    // ------------------------------------------------------------------------
    // Evaluacio de l'adressa de salt
    // ------------------------------------------------------------------------

    InstAddr brAlu_pc;

    BranchAlu
    brAlu(
        .i_op      (dpCtrl_pcNextSel),
        .i_pc      (i_pc),
        .i_instIMM (dec_instIMM),
        .i_regData (regs_dataA),
        .o_pc      (brAlu_pc));


    // ------------------------------------------------------------------------
    // Interficie amb el bloc de registres.
    // ------------------------------------------------------------------------

    Data regs_dataA;
    Data regs_dataB;

    assign regBus.rdAddrA = dec_instRS1;
    assign regBus.rdAddrB = dec_instRS2;
    assign regs_dataA     = regBus.rdDataA;
    assign regs_dataB     = regBus.rdDataB;


    // ------------------------------------------------------------------------
    // Asignacio de les sortides
    // ------------------------------------------------------------------------

    always_comb begin
        o_instIMM      = dec_instIMM;
        o_dataA        = fwdDataASelector_output;
        o_dataB        = fwdDataBSelector_output;
        o_regWrAddr    = dec_instRD;
        o_regWrEnable  = dpCtrl_regWrEnable;
        o_regWrDataSel = dpCtrl_dataToRegSel;
        o_memWrEnable  = dpCtrl_memWrEnable;
        o_memRdEnable  = dpCtrl_memRdEnable;
        o_memAccess    = dpCtrl_memAccess;
        o_memUnsigned  = dpCtrl_memUnsigned;
        o_operandASel  = dpCtrl_operandASel;
        o_operandBSel  = dpCtrl_operandBSel;
        o_aluControl   = dpCtrl_aluControl;
        o_pcNext       = brAlu_pc;
    end


endmodule
