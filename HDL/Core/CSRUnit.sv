module CSRUnit
    import Config::*, Types::*;
(
    // Senyals de control
    input  logic   i_clock,   // Clock
    input  logic   i_reset,   // Reset

    // Senyals de control dels contadors
    input  logic   i_instRet, // Indica instruccio retirada

    // Senyals d'acces als registres
    input  CsrOp   i_op,      // Operacio a realitzar
    input  CSRAddr i_csr,     // Identificador del registre
    input  Data    i_data,    // Entrada de dades
    output Data    o_data);   // Sortida de dades


    localparam int unsigned MISA_XLEN = DATA_WIDTH == 32 ? 1 : 2;
    localparam Data MISA =
        (int'(RV_EXT_A)  <<  0) | // A - Atomic Instructions extension
        (0               <<  1) | // B - Bitfield extension
        (int'(RV_EXT_C)  <<  2) | // C - Compressed extension
        (int'(RV_EXT_D)  <<  3) | // D - Double precision floating-point extension
        (int'(RV_EXT_E)  <<  4) | // E - Reduced register number extension
        (int'(RV_EXT_F)  <<  5) | // F - Single precision floating-point extension
        (int'(RV_EXT_I)  <<  8) | // I - Integer extension
        (int'(RV_EXT_M)  << 12) | // M - Integer Multiply/Divide extension
        (0               << 13) | // N - User level interrupts supported
        (0               << 18) | // S - Supervisor mode implemented
        (int'(RV_EXT_U)  << 20) | // U - User mode implemented
        (0               << 23) | // X - Non-standard extensions present
        (MISA_XLEN       << 30);  // M-XLEN 32bit
    localparam MVENDORID = 0;
    localparam MARCHID   = 0;
    localparam MIMPID    = 0;
    localparam MHARTID   = 0;

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
    localparam CSR_MHPMCOUNTER10 = 12'hB8A;
    localparam CSR_MHPMCOUNTER11 = 12'hB8B;
    localparam CSR_MHPMCOUNTER12 = 12'hB8C;
    localparam CSR_MHPMCOUNTER13 = 12'hB8D;
    localparam CSR_MHPMCOUNTER14 = 12'hB8E;
    localparam CSR_MHPMCOUNTER15 = 12'hB8F;
    localparam CSR_MHPMCOUNTER16 = 12'hB90;
    localparam CSR_MHPMCOUNTER17 = 12'hB91;
    localparam CSR_MHPMCOUNTER18 = 12'hB92;
    localparam CSR_MHPMCOUNTER19 = 12'hB93;
    localparam CSR_MHPMCOUNTER20 = 12'hB94;
    localparam CSR_MHPMCOUNTER21 = 12'hB95;
    localparam CSR_MHPMCOUNTER22 = 12'hB96;
    localparam CSR_MHPMCOUNTER23 = 12'hB97;
    localparam CSR_MHPMCOUNTER24 = 12'hB98;
    localparam CSR_MHPMCOUNTER25 = 12'hB99;
    localparam CSR_MHPMCOUNTER26 = 12'hB9A;
    localparam CSR_MHPMCOUNTER27 = 12'hB9B;
    localparam CSR_MHPMCOUNTER28 = 12'hB9C;
    localparam CSR_MHPMCOUNTER29 = 12'hB9D;
    localparam CSR_MHPMCOUNTER30 = 12'hB9E;
    localparam CSR_MHPMCOUNTER31 = 12'hB9F;


    RunMode mode;      // Modus d'execucio

    Data cycle;        // Contador de cicles
    Data instret;      // Contador d'instruccions retirades
    Data hpmcounter3;  //
    Data hpmcounter4;  //
    Data hpmcounter5;  //
    Data hpmcounter6;  //
    Data hpmcounter7;  //
    Data hpmcounter8;  //
    Data hpmcounter9;  //
    Data hpmcounter10; //
    Data hpmcounter11; //
    Data hpmcounter12; //
    Data hpmcounter13; //
    Data hpmcounter14; //
    Data hpmcounter15; //
    Data hpmcounter16; //
    Data hpmcounter17; //
    Data hpmcounter18; //
    Data hpmcounter19; //
    Data hpmcounter20; //
    Data hpmcounter21; //
    Data hpmcounter22; //
    Data hpmcounter23; //
    Data hpmcounter24; //
    Data hpmcounter25; //
    Data hpmcounter26; //
    Data hpmcounter27; //
    Data hpmcounter28; //
    Data hpmcounter29; //
    Data hpmcounter30; //
    Data hpmcounter31; //

    Data                        mtime;      // Contador de temps
    Data                        mtimecmp;   // Comparador del contador de temps
    Data                        mcause;
    Data                        mscratch;
    Data                        mstatus;
    logic [1:0]                 mtvec_MODE;
    logic [$size(InstAddr)-3:0] mtvec_BASE;
    logic                       mip_MEIP;
    logic                       mip_MTIP;
    logic                       mip_MSIP;
    logic                       mie_MEIE;
    logic                       mie_MTIE;
    logic                       mie_MSIE;
    logic                       mcounteren_CY;
    logic                       mcounteren_IR;
    logic                       mcountinhibit_CY; // Inhibeix el contador de cicles
    logic                       mcountinhibit_IR; // Inhibeix el contador d'instruccions


    Data dataIn;
    Data dataOut;
    logic isNOP;


    assign isNOP = i_op == CsrOp_NOP;

    always_comb
        unique case (i_op)
            CsrOp_SET   : dataIn = dataOut | i_data;
            CsrOp_CLEAR : dataIn = dataOut & ~i_data;
            default     : dataIn = i_data;
        endcase

    always_ff @(posedge i_clock)
        if (i_reset)
            cycle <= 0;
        else if ((i_csr == CSR_MCYCLE) & ~isNOP)
            cycle <= dataIn;
        else if (~mcountinhibit_CY)
            cycle <= cycle + 1;

    always_ff @(posedge i_clock)
        if (i_reset)
            instret <= 0;
        else if ((i_csr == CSR_MINSTRET) & ~isNOP)
            instret <= dataIn;
        else if (~mcountinhibit_IR & i_instRet)
            instret <= instret + 1;

    always_ff @(posedge i_clock)
        if (i_reset) begin
            mcounteren_CY    <= 1'b0;
            mcounteren_IR    <= 1'b0;
            mcountinhibit_CY <= 1'b1;
            mcountinhibit_IR <= 1'b1;
            mtvec_BASE       <= 0;
            mtvec_MODE       <= 0;
        end
        else
            case (i_csr)
                CSR_MCAUSE:
                    mcause <= dataIn;

                CSR_MCOUNTEREN:
                    begin
                        mcounteren_IR <= dataIn[2];
                        mcounteren_CY <= dataIn[0];
                    end

                CSR_MCOUNTINHIBIT:
                    begin
                        mcountinhibit_IR <= dataIn[2];
                        mcountinhibit_CY <= dataIn[0];
                    end

                CSR_MIE:
                    begin
                        mie_MEIE <= dataIn[11];
                        mie_MTIE <= dataIn[7];
                        mie_MSIE <= dataIn[3];
                    end

                CSR_MIP:
                    begin
                        mip_MEIP <= dataIn[11];
                        mip_MTIP <= dataIn[7];
                        mip_MSIP <= dataIn[3];
                    end

                CSR_MSCRATCH:
                    mscratch <= dataIn;

                CSR_MSTATUS:
                    mstatus <= dataIn;

                CSR_MTVEC:
                    begin
                        mtvec_MODE <= dataIn[1:0];
                        mtvec_BASE <= dataIn[$size(Data)-1:2];
                    end

                default:
                    ;
            endcase

    always_comb begin
        case (i_csr)
            CSR_MVENDORID     : dataOut = MVENDORID;
            CSR_MARCHID       : dataOut = MARCHID;
            CSR_MIMPID        : dataOut = MIMPID;
            CSR_MHARTID       : dataOut = MHARTID;
            CSR_MCAUSE        : dataOut = mcause;
            CSR_MCOUNTEREN    : dataOut = Data'({mcounteren_IR, 1'b0, mcounteren_CY});
            CSR_MCOUNTINHIBIT : dataOut = Data'({mcountinhibit_IR, 1'b0, mcountinhibit_CY});
            CSR_MIE           : dataOut = Data'({mie_MEIE, 3'b000, mie_MTIE, 3'b000, mie_MSIE, 3'b000});
            CSR_MIP           : dataOut = Data'({mip_MEIP, 3'b000, mip_MTIP, 3'b000, mip_MSIP, 3'b000});
            CSR_MCYCLE        : dataOut = cycle;
            CSR_MINSTRET      : dataOut = instret;
            CSR_MHPMCOUNTER3  : dataOut = hpmcounter3;
            CSR_MHPMCOUNTER4  : dataOut = hpmcounter4;
            CSR_MHPMCOUNTER5  : dataOut = hpmcounter5;
            CSR_MHPMCOUNTER6  : dataOut = hpmcounter6;
            CSR_MHPMCOUNTER7  : dataOut = hpmcounter7;
            CSR_MHPMCOUNTER8  : dataOut = hpmcounter8;
            CSR_MHPMCOUNTER9  : dataOut = hpmcounter9;
            CSR_MHPMCOUNTER10 : dataOut = hpmcounter10;
            CSR_MHPMCOUNTER11 : dataOut = hpmcounter11;
            CSR_MHPMCOUNTER12 : dataOut = hpmcounter12;
            CSR_MHPMCOUNTER13 : dataOut = hpmcounter13;
            CSR_MHPMCOUNTER14 : dataOut = hpmcounter14;
            CSR_MHPMCOUNTER15 : dataOut = hpmcounter15;
            CSR_MHPMCOUNTER16 : dataOut = hpmcounter16;
            CSR_MHPMCOUNTER17 : dataOut = hpmcounter17;
            CSR_MHPMCOUNTER18 : dataOut = hpmcounter18;
            CSR_MHPMCOUNTER19 : dataOut = hpmcounter19;
            CSR_MHPMCOUNTER20 : dataOut = hpmcounter20;
            CSR_MHPMCOUNTER21 : dataOut = hpmcounter21;
            CSR_MHPMCOUNTER22 : dataOut = hpmcounter22;
            CSR_MHPMCOUNTER23 : dataOut = hpmcounter23;
            CSR_MHPMCOUNTER24 : dataOut = hpmcounter24;
            CSR_MHPMCOUNTER25 : dataOut = hpmcounter25;
            CSR_MHPMCOUNTER26 : dataOut = hpmcounter26;
            CSR_MHPMCOUNTER27 : dataOut = hpmcounter27;
            CSR_MHPMCOUNTER28 : dataOut = hpmcounter28;
            CSR_MHPMCOUNTER29 : dataOut = hpmcounter29;
            CSR_MHPMCOUNTER30 : dataOut = hpmcounter30;
            CSR_MHPMCOUNTER31 : dataOut = hpmcounter31;
            CSR_MISA          : dataOut = MISA;
            CSR_MSCRATCH      : dataOut = mscratch;
            CSR_MSTATUS       : dataOut = mstatus;
            CSR_MTVEC         : dataOut = Data'({mtvec_BASE, mtvec_MODE});
            default           : dataOut = Data'(0);
        endcase
    end

    assign o_data = dataOut;


endmodule
