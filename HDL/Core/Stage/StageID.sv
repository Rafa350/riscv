module StageID
    import Types::*;
(
    // Senyals de control i sincronitzacio
    input  logic             i_clock,           // Clock
    input  logic             i_reset,           // Reset

    // Interficie amb el bloc de registres
    GPRegistersBus.masterReader regBus,            // Bus d'acces als registres per lectura

    // Senyals del stage EX per la gestio dels hazards
    input  logic             i_EX_isValid,      // Indica operacio valida en EX
    input  GPRAddr           i_EX_regWrAddr,    // Registre per escriure en EX
    input  logic             i_EX_regWrEnable,  // Habilita l'escriptura en el registre en EX
    input  logic [1:0]       i_EX_regWrDataSel, // Seleccio de dades en EX
    input  Data              i_EX_regWrData,    // Dades a escriure en el registre en EX
    input  logic             i_EX_memRdEnable,  // Habilita la lectura de memoria en EX

    // Senyals del stage MEM per la gestio dels hazards
    input  logic             i_MEM_isValid,     // Indica operacio valida
    input  GPRAddr           i_MEM_regWrAddr,   // Registre per escriure
    input  logic             i_MEM_regWrEnable, // Habilita l'escriptura
    input  Data              i_MEM_regWrData,   // Dades a escriure
    input  logic             i_MEM_memRdEnable, // Habilita la lectura de memoria

    // Senyals del stage WB per la gestio dels hazards
    input  logic             i_WB_isValid,      // Indica operacio valid
    input  GPRAddr           i_WB_regWrAddr,    // Registre a escriure
    input  logic             i_WB_regWrEnable,  // Autoritzacio d'escriptura en registre
    input  Data              i_WB_regWrData,    // El valor a escriure en el registre

    // Senyals operatives del stage
    input  Inst              i_inst,            // Instruccio
    input  logic             i_instCompressed,  // Indica que es una instruccio comprimida
    input  InstAddr          i_pc,              // Adressa de la instruccio
    output Data              o_instIMM,         // Valor IMM de la instruccio
    output CSRAddr           o_instCSR,         // Valor CSR de la instruccio
    output Data              o_dataRS1,         // Valor del registre X[RS1]
    output Data              o_dataRS2,         // Valor del registre X[RS2]
    output logic             o_hazard,          // Indica hazard
    output GPRAddr           o_regWrAddr,       // Registre a escriure X(RD)
    output logic             o_regWrEnable,     // Habilita l'escriptura del registre
    output logic [1:0]       o_regWrDataSel,    // Seleccio de les dades per escriure en el registre
    output logic             o_memWrEnable,     // Habilita l'escritura en memoria
    output logic             o_memRdEnable,     // Habilita la lectura de la memoria
    output DataAccess        o_memAccess,       // Tamany d'acces a la memoria
    output logic             o_memUnsigned,     // Lectura de memoria sense signe
    output DataASel          o_operandASel,     // Seleccio del valor A
    output DataBSel          o_operandBSel,     // Seleccio del valor B
    output logic [1:0]       o_resultSel,       // Seleccio del resultat
    output AluOp             o_aluControl,      // Selecciona l'operacio de la unitat ALU
    output MduOp             o_mduControl,      // Selecciona l'operacio en la unitat MDU
    output CsrOp             o_csrControl,      // Selecciona l'operacio en la unitat CSR
    output InstAddr          o_pcNext);         // Nou valor de PC


    assign o_instIMM = dec_instIMM;
    assign o_dataRS1 = fwdDataRS1Selector_output;
    assign o_dataRS2 = fwdDataRS2Selector_output;


    // ------------------------------------------------------------------------
    // Decodificador d'instruccions.
    // Separa les instruccions en els seus components, calculant el valor
    // IMM de la instruccio en funcio del seu tipus.
    // ------------------------------------------------------------------------

    GPRAddr dec_instRS1;   // Registre RS1
    GPRAddr dec_instRS2;   // Registre RS2
    Data    dec_instIMM;   // Valor inmediat

    // verilator lint_off PINMISSING
    InstDecoder
    dec (
        .i_inst      (i_inst),       // La instruccio a decodificar
        .o_instRS1   (dec_instRS1),  // El parametre RS1
        .o_instRS2   (dec_instRS2),  // El parametre RS2
        .o_instRD    (o_regWrAddr),  // El parametre RD
        .o_instIMM   (dec_instIMM),  // El parametre IMM
        .o_instCSR   (o_instCSR));   // El parametre CSR
    // verilator lint_on PINMISSING


    // ------------------------------------------------------------------------
    // Controlador del datapath.
    // Genera les senyals de control de les rutes de dades.
    // ------------------------------------------------------------------------

    logic       dpCtrl_cmpUnsigned;  // Comparacio sense signe
    logic [1:0] dpCtrl_pcNextSel;    // Selector del seguent valor del PC

    DatapathController
    dpCtrl (
        .i_inst           (i_inst),                // La instruccio
        .i_isEqual        (brComp_isEqual),        // Indicador r1 == r2
        .i_isLessSigned   (brComp_isLessSigned),   // Indicador r1 < r2 amb signe
        .i_isLessUnsigned (brComp_isLessUnsigned), // Indicador r1 < r2 amb signe
        .o_memWrEnable    (o_memWrEnable),
        .o_memAccess      (o_memAccess),           // Tamany d'acces a la memoria
        .o_memUnsigned    (o_memUnsigned),         // Lectura de memoria sense signe
        .o_memRdEnable    (o_memRdEnable),
        .o_regWrEnable    (o_regWrEnable),
        .o_regWrDataSel   (o_regWrDataSel),
        .o_aluControl     (o_aluControl),
        .o_mduControl     (o_mduControl),
        .o_csrControl     (o_csrControl),
        .o_operandASel    (o_operandASel),
        .o_operandBSel    (o_operandBSel),
        .o_resultSel      (o_resultSel),
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

    logic [1:0] fwdCtrl_dataRS1Sel;
    logic [1:0] fwdCtrl_dataRS2Sel;
    Data        fwdDataRS1Selector_output;
    Data        fwdDataRS2Selector_output;

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
        .o_dataRS1Sel      (fwdCtrl_dataRS1Sel),  // Origen de les dades de RS1
        .o_dataRS2Sel      (fwdCtrl_dataRS2Sel)); // Origen de les dades de RS2

    Mux4To1 #(
        .WIDTH ($size(Data)))
    fwdDataRS1Selector (
        .i_select (fwdCtrl_dataRS1Sel),
        .i_input0 (regs_dataA),
        .i_input1 (i_EX_regWrData),
        .i_input2 (i_MEM_regWrData),
        .i_input3 (i_WB_regWrData),
        .o_output (fwdDataRS1Selector_output)); // Valor del registre RS1

    Mux4To1 #(
        .WIDTH ($size(Data)))
    fwdDataRS2Selector (
        .i_select (fwdCtrl_dataRS2Sel),
        .i_input0 (regs_dataB),
        .i_input1 (i_EX_regWrData),
        .i_input2 (i_MEM_regWrData),
        .i_input3 (i_WB_regWrData),
        .o_output (fwdDataRS2Selector_output)); // Valor del registre RS2


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
        .i_dataRS1        (fwdDataRS1Selector_output),
        .i_dataRS2        (fwdDataRS2Selector_output),
        .o_isEqual        (brComp_isEqual),
        .o_isLessSigned   (brComp_isLessSigned),
        .o_isLessUnsigned (brComp_isLessUnsigned));


    // ------------------------------------------------------------------------
    // Evaluacio de l'adressa de salt
    // ------------------------------------------------------------------------

    BranchAlu
    brAlu(
        .i_op      (dpCtrl_pcNextSel),
        .i_pc      (i_pc),
        .i_instIMM (dec_instIMM),
        .i_regData (regs_dataA),
        .o_pc      (o_pcNext));


    // ------------------------------------------------------------------------
    // Interficie amb el bloc de registres.
    // ------------------------------------------------------------------------

    Data regs_dataA;
    Data regs_dataB;

    assign regBus.rdAddrA = dec_instRS1;
    assign regBus.rdAddrB = dec_instRS2;
    assign regs_dataA     = regBus.rdDataA;
    assign regs_dataB     = regBus.rdDataB;


endmodule
