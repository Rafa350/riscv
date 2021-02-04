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


    localparam MISA_XLEN = DATA_WIDTH == 32 ? 1 : 2;
    localparam Data MISA =
        (RV_EXT_A  <<  0) | // A - Atomic Instructions extension
        (0         <<  1) | // B - Bitfield extension
        (RV_EXT_C  <<  2) | // C - Compressed extension
        (RV_EXT_D  <<  3) | // D - Double precision floating-point extension
        (RV_EXT_E  <<  4) | // E - Reduced register number extension
        (RV_EXT_F  <<  5) | // F - Single precision floating-point extension
        (RV_EXT_I  <<  8) | // I - Integer extension
        (RV_EXT_M  << 12) | // M - Integer Multiply/Divide extension
        (0         << 13) | // N - User level interrupts supported
        (0         << 18) | // S - Supervisor mode implemented
        (RV_EXT_U  << 20) | // U - User mode implemented
        (0         << 23) | // X - Non-standard extensions present
        (MISA_XLEN << 30);  // M-XLEN 32bit
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
            unique case (i_csr)
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
        unique case (i_csr)
            CSR_MVENDORID     : dataOut = MVENDORID;
            CSR_MARCHID       : dataOut = MARCHID;
            CSR_MIMPID        : dataOut = MIMPID;
            CSR_MHARTID       : dataOut = MHARTID;
            CSR_MCAUSE        : dataOut = mcause;
            CSR_MCYCLE        : dataOut = cycle;
            CSR_MCOUNTEREN    : dataOut = Data'({mcounteren_IR, 1'b0, mcounteren_CY});
            CSR_MCOUNTINHIBIT : dataOut = Data'({mcountinhibit_IR, 1'b0, mcountinhibit_CY});
            CSR_MIE           : dataOut = Data'({mie_MEIE, 3'b000, mie_MTIE, 3'b000, mie_MSIE, 3'b000});
            CSR_MIP           : dataOut = Data'({mip_MEIP, 3'b000, mip_MTIP, 3'b000, mip_MSIP, 3'b000});
            CSR_MINSTRET      : dataOut = instret;
            CSR_MISA          : dataOut = MISA;
            CSR_MSCRATCH      : dataOut = mscratch;
            CSR_MSTATUS       : dataOut = mstatus;
            CSR_MTVEC         : dataOut = Data'({mtvec_BASE, mtvec_MODE});
            default           : dataOut = Data'(0);
        endcase
    end

    assign o_data = dataOut;


endmodule
