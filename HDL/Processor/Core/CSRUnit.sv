module CSRUnit
    import Config::*, CoreDefs::*;
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

    localparam CSR_CYCLE         = 12'hC00;
    localparam CSR_TIME          = 12'hC01;
    localparam CSR_TIMEH         = 12'hC81;
    localparam CSR_INSTRET       = 12'hC02;
    localparam CSR_INSTRETH      = 12'hC82;

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
    localparam CSR_MHPMCOUNTER3  = 12'hB03;
    localparam CSR_MHPMCOUNTER3H = 12'hB83;
    localparam CSR_MHPMCOUNTER4  = 12'hB04;
    localparam CSR_MHPMCOUNTER4H = 12'hB84;
    localparam CSR_MHPMCOUNTER5  = 12'hB05;
    localparam CSR_MHPMCOUNTER5H = 12'hB85;
    localparam CSR_MHPMCOUNTER6  = 12'hB06;
    localparam CSR_MHPMCOUNTER6H = 12'hB86;
    localparam CSR_MHPMCOUNTER7  = 12'hB07;
    localparam CSR_MHPMCOUNTER7H = 12'hB87;
    localparam CSR_MHPMCOUNTER8  = 12'hB08;
    localparam CSR_MHPMCOUNTER8H = 12'hB88;
    localparam CSR_MHPMCOUNTER9  = 12'hB09;
    localparam CSR_MHPMCOUNTER9H = 12'hB89;
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
    logic [31:0]                 hpmData[HPM_NUM_COUNTERS];     // Valor per escriure en el contador
    logic [32:0]                 hpmCounter[HPM_NUM_COUNTERS];  // Valor actual del contador
    logic [HPM_NUM_COUNTERS-1:0] hpmInhibit;                    // Inhibicio del contador
    logic [HPM_NUM_COUNTERS-1:0] hpmWrite;                      // Habilita la escriptura de dades en el contador
    logic [3:0]                  hpmEvent[HPM_NUM_COUNTERS];    // Events asignats als contadors
    logic [HPM_NUM_COUNTERS-1:0] hpmTrigger;                    // Trigger del contador

    // Lectura i escriptura dels registres
    //
    Data  wdata;         // Dades procesades per escriure en el registre
    Data  rdata;         // Dades lleigides del registre
    logic illegalCsr;    // Indicador de registre il·legal
    logic illegalAccess; // Indicador d'acces il·legal


    // -------------------------------------------------------------------
    // Actualitzacio dels contadors de rendiment
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
                hpmCounter[i] <= {1'b0, hpmData[i]};
            else if (~hpmInhibit[i] & hpmTrigger[i])
                hpmCounter[i] <= hpmCounter[i] + 1;
        end
    end


    // -------------------------------------------------------------------
    // Escriptura sincrona dels valors dels registres
    // -------------------------------------------------------------------

    always_comb begin
        unique case (i_op)
            CsrOp_SET:
                wdata = rdata | i_data;

            CsrOp_CLEAR:
                wdata = rdata & ~i_data;

            default:
                wdata = i_data;
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
        else if ((i_op != CsrOp_NOP) & ~illegalCsr & ~illegalAccess)
            // verilator lint_off CASEINCOMPLETE
            unique case (i_csr)
                CSR_MCAUSE: mcause <= wdata;

                CSR_MIE: begin
                    mie_MEIE <= wdata[11];
                    mie_MTIE <= wdata[7];
                    mie_MSIE <= wdata[3];
                end

                CSR_MIP: begin
                    mip_MEIP <= wdata[11];
                    mip_MTIP <= wdata[7];
                    mip_MSIP <= wdata[3];
                end

                CSR_MSCRATCH: mscratch <= wdata;

                CSR_MSTATUS: begin
                    mstatus_MIE  <= wdata[3];
                    mstatus_MPRV <= wdata[17];
                end

                CSR_MTVEC: begin
                    mtvec_MODE <= wdata[1:0];
                    mtvec_BASE <= wdata[$size(Data)-1:2];
                end

                CSR_MCOUNTINHIBIT: begin
                    hpmInhibit <= wdata[HPM_NUM_COUNTERS-1:0];
                end

                CSR_MCYCLE: begin
                    hpmData[0] <= wdata;
                    hpmWrite[0] <= 1'b1;
                end

                CSR_MINSTRET: begin
                    hpmData[2] <= wdata;
                    hpmWrite[2] <= 1'b1;
                end

                CSR_MHPMCOUNTER3: begin
                    hpmData[3] <= wdata;
                    hpmWrite[3] <= 1'b1;
                end

                CSR_MHPMCOUNTER4: begin
                    hpmData[4] <= wdata;
                    hpmWrite[4] <= 1'b1;
                end

                CSR_MHPMCOUNTER5: begin
                    hpmData[5] <= wdata;
                    hpmWrite[5] <= 1'b1;
                end

                CSR_MHPMCOUNTER6: begin
                    hpmData[6] <= wdata;
                    hpmWrite[6] <= 1'b1;
                end

                CSR_MHPMCOUNTER7: begin
                    hpmData[7] <= wdata;
                    hpmWrite[7] <= 1'b1;
                end

                CSR_MHPMCOUNTER8: begin
                    hpmData[8] <= wdata;
                    hpmWrite[8] <= 1'b1;
                end

                CSR_MHPMCOUNTER9: begin
                    hpmData[9] <= wdata;
                    hpmWrite[9] <= 1'b1;
                end

                CSR_MHPMEVENT3: hpmEvent[3] <= wdata[3:0];
                CSR_MHPMEVENT4: hpmEvent[4] <= wdata[3:0];
                CSR_MHPMEVENT5: hpmEvent[5] <= wdata[3:0];
                CSR_MHPMEVENT6: hpmEvent[6] <= wdata[3:0];
                CSR_MHPMEVENT7: hpmEvent[7] <= wdata[3:0];
                CSR_MHPMEVENT8: hpmEvent[8] <= wdata[3:0];
                CSR_MHPMEVENT9: hpmEvent[9] <= wdata[3:0];
            endcase
            // verilator lint_on CASEINCOMPLETE

        else
            hpmWrite <= 0;
    end


    // -------------------------------------------------------------------
    // Lectura asincrona del valor dels registres
    // -------------------------------------------------------------------

    always_comb begin

        rdata = Data'(0);

        illegalCsr = 1'b0;
        illegalAccess = i_csr[9:8] != mode;

        if (~illegalAccess)
            unique case (i_csr)
                CSR_MVENDORID     : rdata = MVENDORID;
                CSR_MARCHID       : rdata = MARCHID;
                CSR_MIMPID        : rdata = MIMPID;
                CSR_MHARTID       : rdata = MHARTID;
                CSR_MCAUSE        : rdata = mcause;
                CSR_MEPC          : rdata = mepc;
                CSR_MIE           : rdata = Data'({mie_MEIE, 3'b0, mie_MTIE, 3'b0, mie_MSIE, 3'b0});
                CSR_MIP           : rdata = Data'({mip_MEIP, 3'b0, mip_MTIP, 3'b0, mip_MSIP, 3'b0});
                CSR_MISA          : rdata = MISA;
                CSR_MSCRATCH      : rdata = mscratch;
                CSR_MSTATUS       : rdata = Data'({mstatus_MPRV, 13'b0, mstatus_MIE, 3'b0});
                CSR_MTVEC         : rdata = Data'({mtvec_BASE, mtvec_MODE});

                CSR_MCOUNTINHIBIT : rdata = Data'(hpmInhibit);
                CSR_MCYCLE        : rdata = hpmCounter[0][31:0];
                CSR_MCYCLEH       : rdata = Data'(hpmCounter[0][32]);
                CSR_MINSTRET      : rdata = hpmCounter[2][31:0];
                CSR_MINSTRETH     : rdata = Data'(hpmCounter[2][32]);
                CSR_MHPMCOUNTER3  : rdata = hpmCounter[3][31:0];
                CSR_MHPMCOUNTER3H : rdata = Data'(hpmCounter[3][32]);
                CSR_MHPMCOUNTER4  : rdata = hpmCounter[4][31:0];
                CSR_MHPMCOUNTER4H : rdata = Data'(hpmCounter[4][32]);
                CSR_MHPMCOUNTER5  : rdata = hpmCounter[5][31:0];
                CSR_MHPMCOUNTER5H : rdata = Data'(hpmCounter[5][32]);
                CSR_MHPMCOUNTER6  : rdata = hpmCounter[6][31:0];
                CSR_MHPMCOUNTER6H : rdata = Data'(hpmCounter[6][32]);
                CSR_MHPMCOUNTER7  : rdata = hpmCounter[7][31:0];
                CSR_MHPMCOUNTER7H : rdata = Data'(hpmCounter[7][32]);
                CSR_MHPMCOUNTER8  : rdata = hpmCounter[8][31:0];
                CSR_MHPMCOUNTER8H : rdata = Data'(hpmCounter[8][32]);
                CSR_MHPMCOUNTER9  : rdata = hpmCounter[9][31:0];
                CSR_MHPMCOUNTER9H : rdata = Data'(hpmCounter[9][32]);

                CSR_MHPMEVENT3    : rdata = Data'(hpmEvent[3]);
                CSR_MHPMEVENT4    : rdata = Data'(hpmEvent[4]);
                CSR_MHPMEVENT5    : rdata = Data'(hpmEvent[5]);
                CSR_MHPMEVENT6    : rdata = Data'(hpmEvent[6]);
                CSR_MHPMEVENT7    : rdata = Data'(hpmEvent[7]);
                CSR_MHPMEVENT8    : rdata = Data'(hpmEvent[8]);
                CSR_MHPMEVENT9    : rdata = Data'(hpmEvent[9]);

                default: illegalCsr = 1'b1;
            endcase
    end

    assign o_data = rdata;


endmodule
