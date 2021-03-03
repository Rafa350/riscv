module CSRUnit
    import Config::*, Types::*;
(
    // Senyals de control
    input  logic   i_clock,       // Clock
    input  logic   i_reset,       // Reset

    // Senyals de control dels contadors HPM
    input  logic   i_evInstRet,   // Indica instruccio retirada
    input  logic   i_evICacheMis, // Falla en el cache d'instruccions
    input  logic   i_evICacheHit, // Encert en el cache d'instruccions
    input  logic   i_evDCacheMis, // Falla en el cache de dades
    input  logic   i_evDCacheHit, // Encert en el cache de dades
    input  logic   i_evMemRead,   // Memeoria lleigida
    input  logic   i_evMemWrite,  // Memoria escrita

    // Senyals d'acces als registres
    input  CsrOp   i_op,          // Operacio a realitzar
    input  CSRAddr i_csr,         // Identificador del registre
    input  Data    i_data,        // Entrada de dades
    output Data    o_data);       // Sortida de dades


    localparam logic [1:0] MISA_XLEN = $size(Data) == 32 ? 2'b01 : 2'b10;
    localparam Data MISA =
        (Data'(RV_EXT_A)  <<  0) | // A - Atomic Instructions extension
        (0                <<  1) | // B - Bitfield extension
        (Data'(RV_EXT_C)  <<  2) | // C - Compressed extension
        (Data'(RV_EXT_D)  <<  3) | // D - Double precision floating-point extension
        (Data'(RV_EXT_E)  <<  4) | // E - Reduced register number extension
        (Data'(RV_EXT_F)  <<  5) | // F - Single precision floating-point extension
        (Data'(RV_EXT_I)  <<  8) | // I - Integer extension
        (Data'(RV_EXT_M)  << 12) | // M - Integer Multiply/Divide extension
        (0                << 13) | // N - User level interrupts supported
        (0                << 18) | // S - Supervisor mode implemented
        (Data'(RV_EXT_U)  << 20) | // U - User mode implemented
        (0                << 23) | // X - Non-standard extensions present
        (Data'(MISA_XLEN) << 30);  // M-XLEN 32bit
    localparam Data MVENDORID = 0;
    localparam Data MARCHID   = 0;
    localparam Data MIMPID    = 0;
    localparam Data MHARTID   = 0;

    localparam CSR_MVENDORID     = 12'hF11;
    localparam CSR_MARCHID       = 12'hF12;
    localparam CSR_MIMPID        = 12'hF13;
    localparam CSR_MHARTID       = 12'hF14;
    localparam CSR_MSTATUS       = 12'h300;
    localparam CSR_MISA          = 12'h301;
    localparam CSR_MIE           = 12'h304;
    localparam CSR_MTVEC         = 12'h305;
    localparam CSR_MCOUNTEREN    = 12'h306;
    localparam CSR_MCOUNTINHIBIT = 12'h320;
    localparam CSR_MSCRATCH      = 12'h340;
    localparam CSR_MEPC          = 12'h341;
    localparam CSR_MCAUSE        = 12'h342;
    localparam CSR_MIP           = 12'h344;
    localparam CSR_MCYCLE        = 12'hB00;
    localparam CSR_MCYCLEH       = 12'hB80;
    localparam CSR_MINSTRET      = 12'hB02;
    localparam CSR_MINSTRETH     = 12'hB82;
    localparam CSR_MHPMCOUNTER3  = 12'hB83;
    localparam CSR_MHPMCOUNTER4  = 12'hB84;
    localparam CSR_MHPMCOUNTER5  = 12'hB85;
    localparam CSR_MHPMCOUNTER6  = 12'hB86;
    localparam CSR_MHPMCOUNTER7  = 12'hB87;
    localparam CSR_MHPMCOUNTER8  = 12'hB88;
    localparam CSR_MHPMCOUNTER9  = 12'hB89;
    localparam CSR_MHPMEVENT3    = 12'h323;
    localparam CSR_MHPMEVENT4    = 12'h324;
    localparam CSR_MHPMEVENT5    = 12'h325;
    localparam CSR_MHPMEVENT6    = 12'h326;
    localparam CSR_MHPMEVENT7    = 12'h327;
    localparam CSR_MHPMEVENT8    = 12'h328;
    localparam CSR_MHPMEVENT9    = 12'h329;

    localparam HPM_NUM_COUNTERS  = 10;             // Nombre de contadors de rendiment


    RunMode                      mode;             // Modus d'execucio

    // Senyals d'estat i control
    Data                         mepc;             // Salva PC durant les excepcions
    Data                         mcause;
    Data                         mscratch;
    logic                        mstatus_MIE;
    logic                        mstatus_MPRV;
    logic [1:0]                  mtvec_MODE;
    logic [$size(InstAddr)-3:0]  mtvec_BASE;
    logic                        mip_MEIP;
    logic                        mip_MTIP;
    logic                        mip_MSIP;
    logic                        mie_MEIE;
    logic                        mie_MTIE;
    logic                        mie_MSIE;

    // Contadors de rendiment
    //
    Data                         hpmData[HPM_NUM_COUNTERS];     // Valor per escriure en el contador
    Data                         hpmCounter[HPM_NUM_COUNTERS];  // Valor actual del contador
    logic [HPM_NUM_COUNTERS-1:0] hpmInhibit;                    // Inhibicio del contador
    logic [HPM_NUM_COUNTERS-1:0] hpmWrite;                      // Habilita la escriptura de dades en el contador
    logic [3:0]                  hpmEvent[HPM_NUM_COUNTERS];    // Events asignats als contadors
    logic [HPM_NUM_COUNTERS-1:0] hpmTrigger;                    // Trigger del contador

    // Lectura i escriptura dels registres
    //
    Data  dataIn;     // Dades procesades per escriure en el registre
    Data  dataOut;    // Dades lleigides del registre
    logic illegalCsr; // Indicador de registre il·legal


    // -------------------------------------------------------------------
    // Gestio dels contadors de rendiment
    // -El contador 0 esta reservet (CYCLE)
    // -El contator 2 esta reservat (INSTRET)
    // -------------------------------------------------------------------

    always_comb begin

        // Contador 0 (cycle), es dispara sempre
        hpmTrigger[0] = 1'b1;

        hpmTrigger[1] = 1'b0;

        // Contador 2 (instret) es dispara quen es retira una instruccio
        hpmTrigger[2] = i_evInstRet;

        // Contador 3
        unique case (hpmEvent[3][3:0])
            4'h1: hpmTrigger[3] = i_evICacheHit;
            4'h2: hpmTrigger[3] = i_evICacheMis;
            4'h3: hpmTrigger[3] = i_evDCacheHit;
            4'h4: hpmTrigger[3] = i_evDCacheMis;
            4'h5: hpmTrigger[3] = i_evMemRead;
            4'h6: hpmTrigger[3] = i_evMemWrite;
            default: hpmTrigger[3] = 1'b0;
        endcase

        // Contador 4
        unique case (hpmEvent[4][3:0])
            4'h1: hpmTrigger[4] = i_evICacheHit;
            4'h2: hpmTrigger[4] = i_evICacheMis;
            4'h3: hpmTrigger[4] = i_evDCacheHit;
            4'h4: hpmTrigger[4] = i_evDCacheMis;
            4'h5: hpmTrigger[4] = i_evMemRead;
            4'h6: hpmTrigger[4] = i_evMemWrite;
            default: hpmTrigger[4] = 1'b0;
        endcase

        hpmTrigger[5] = 1'b0;
        hpmTrigger[6] = 1'b0;
        hpmTrigger[7] = 1'b0;
        hpmTrigger[8] = 1'b0;
        hpmTrigger[9] = 1'b0;
    end

    always_ff @(posedge i_clock) begin
        for (int i = 0; i < HPM_NUM_COUNTERS; i++) begin
            if (i_reset)
                hpmCounter[i] <= 0;
            else if (hpmWrite[i])
                hpmCounter[i] <= hpmData[i];
            else if (~hpmInhibit[i] & hpmTrigger[i])
                hpmCounter[i] <= hpmCounter[i] + 1;
        end
    end


    // -------------------------------------------------------------------
    // Escriptura dels registres
    // -------------------------------------------------------------------

    always_comb begin
        unique case (i_op)
            CsrOp_SET:
                dataIn = dataOut | i_data;

            CsrOp_CLEAR:
                dataIn = dataOut & ~i_data;

            default:
                dataIn = i_data;
        endcase
    end

    always_ff @(posedge i_clock) begin
        if (i_reset) begin
            mode         <= RunMode_Machine;
            mtvec_BASE   <= 0;
            mtvec_MODE   <= 0;
            mstatus_MIE  <= 1'b0;
            mstatus_MPRV <= 1'b0;
            hpmWrite     <= {$size(hpmWrite){1'b0}};
            hpmInhibit   <= {$size(hpmInhibit){1'b1}};
            for (int i = 0; i < HPM_NUM_COUNTERS; i++)
                hpmEvent[i] <= 4'h0;
        end
        else if ((i_op != CsrOp_NOP) & ~illegalCsr)
            // verilator lint_off CASEINCOMPLETE
            unique case (i_csr)
                CSR_MCAUSE: mcause <= dataIn;

                CSR_MIE: begin
                    mie_MEIE <= dataIn[11];
                    mie_MTIE <= dataIn[7];
                    mie_MSIE <= dataIn[3];
                end

                CSR_MIP: begin
                    mip_MEIP <= dataIn[11];
                    mip_MTIP <= dataIn[7];
                    mip_MSIP <= dataIn[3];
                end

                CSR_MSCRATCH: mscratch <= dataIn;

                CSR_MSTATUS: begin
                    mstatus_MIE  <= dataIn[3];
                    mstatus_MPRV <= dataIn[17];
                end

                CSR_MTVEC: begin
                    mtvec_MODE <= dataIn[1:0];
                    mtvec_BASE <= dataIn[$size(Data)-1:2];
                end

                CSR_MCOUNTINHIBIT: begin
                    hpmInhibit <= dataIn[HPM_NUM_COUNTERS-1:0];
                end

                CSR_MCYCLE: begin
                    hpmData[0] <= dataIn;
                    hpmWrite[0] <= 1'b1;
                end

                CSR_MINSTRET: begin
                    hpmData[2] <= dataIn;
                    hpmWrite[2] <= 1'b1;
                end

                CSR_MHPMCOUNTER3: begin
                    hpmData[3] <= dataIn;
                    hpmWrite[3] <= 1'b1;
                end

                CSR_MHPMCOUNTER4: begin
                    hpmData[4] <= dataIn;
                    hpmWrite[4] <= 1'b1;
                end

                CSR_MHPMCOUNTER5: begin
                    hpmData[5] <= dataIn;
                    hpmWrite[5] <= 1'b1;
                end

                CSR_MHPMCOUNTER6: begin
                    hpmData[6] <= dataIn;
                    hpmWrite[6] <= 1'b1;
                end

                CSR_MHPMCOUNTER7: begin
                    hpmData[7] <= dataIn;
                    hpmWrite[7] <= 1'b1;
                end

                CSR_MHPMCOUNTER8: begin
                    hpmData[8] <= dataIn;
                    hpmWrite[8] <= 1'b1;
                end

                CSR_MHPMCOUNTER9: begin
                    hpmData[9] <= dataIn;
                    hpmWrite[9] <= 1'b1;
                end

                CSR_MHPMEVENT3: hpmEvent[3] <= dataIn[3:0];
                CSR_MHPMEVENT4: hpmEvent[4] <= dataIn[3:0];
                CSR_MHPMEVENT5: hpmEvent[5] <= dataIn[3:0];
                CSR_MHPMEVENT6: hpmEvent[6] <= dataIn[3:0];
                CSR_MHPMEVENT7: hpmEvent[7] <= dataIn[3:0];
                CSR_MHPMEVENT8: hpmEvent[8] <= dataIn[3:0];
                CSR_MHPMEVENT9: hpmEvent[9] <= dataIn[3:0];
            endcase
            // verilator lint_on CASEINCOMPLETE

        else
            hpmWrite <= 0;
    end


    // -------------------------------------------------------------------
    // Lectura dels registres
    // -------------------------------------------------------------------

    always_comb begin

        illegalCsr = 1'b0;

        unique case (i_csr)
            CSR_MVENDORID     : dataOut = MVENDORID;
            CSR_MARCHID       : dataOut = MARCHID;
            CSR_MIMPID        : dataOut = MIMPID;
            CSR_MHARTID       : dataOut = MHARTID;
            CSR_MCAUSE        : dataOut = mcause;
            CSR_MEPC          : dataOut = mepc;
            CSR_MIE           : dataOut = Data'({mie_MEIE, 3'b0, mie_MTIE, 3'b0, mie_MSIE, 3'b0});
            CSR_MIP           : dataOut = Data'({mip_MEIP, 3'b0, mip_MTIP, 3'b0, mip_MSIP, 3'b0});
            CSR_MISA          : dataOut = MISA;
            CSR_MSCRATCH      : dataOut = mscratch;
            CSR_MSTATUS       : dataOut = Data'({mstatus_MPRV, 13'b0, mstatus_MIE, 3'b0});
            CSR_MTVEC         : dataOut = Data'({mtvec_BASE, mtvec_MODE});

            CSR_MCOUNTINHIBIT : dataOut = Data'(hpmInhibit);
            CSR_MCYCLE        : dataOut = hpmCounter[0];
            CSR_MINSTRET      : dataOut = hpmCounter[2];
            CSR_MHPMCOUNTER3  : dataOut = hpmCounter[3];
            CSR_MHPMCOUNTER4  : dataOut = hpmCounter[4];
            CSR_MHPMCOUNTER5  : dataOut = hpmCounter[5];
            CSR_MHPMCOUNTER6  : dataOut = hpmCounter[6];
            CSR_MHPMCOUNTER7  : dataOut = hpmCounter[7];
            CSR_MHPMCOUNTER8  : dataOut = hpmCounter[8];
            CSR_MHPMCOUNTER9  : dataOut = hpmCounter[9];

            CSR_MHPMEVENT3    : dataOut = Data'(hpmEvent[3]);
            CSR_MHPMEVENT4    : dataOut = Data'(hpmEvent[4]);
            CSR_MHPMEVENT5    : dataOut = Data'(hpmEvent[5]);
            CSR_MHPMEVENT6    : dataOut = Data'(hpmEvent[6]);
            CSR_MHPMEVENT7    : dataOut = Data'(hpmEvent[7]);
            CSR_MHPMEVENT8    : dataOut = Data'(hpmEvent[8]);
            CSR_MHPMEVENT9    : dataOut = Data'(hpmEvent[9]);

            default: begin
                 dataOut = Data'(0);
                 illegalCsr = 1'b1;
            end

        endcase
    end

    assign o_data = dataOut;


endmodule
