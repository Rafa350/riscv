module CSRUnit
    import Config::*, Types::*;
(
    // Senyals de control
    input  logic   i_clock,    // Clock
    input  logic   i_reset,    // Reset

    // Senyals de control dels contadors
    input  logic   i_instRet, // Indica instruccio retirada

    // Senyals operatives
    input  CsrOp   i_op,       // Operacio a realitzar
    input  CSRAddr i_csr,      // Identificador del registre
    input  Data    i_data,     // Entrada de dades
    output Data    o_data);    // Sortida de dades


    localparam MISA_XLEN = DATA_WIDTH == 32 ? 2'b01 : 2'b10;
    localparam Data MISA =
        (0              <<  0) | // A - Atomic Instructions extension
        (32'(RV_EXT_C)  <<  2) | // C - Compressed extension
        (32'(RV_EXT_D)  <<  3) | // D - Double precision floating-point extension
        (32'(RV_EXT_E)  <<  4) | // E - Reduced register number extension
        (32'(RV_EXT_F)  <<  5) | // F - Single precision floating-point extension
        (32'(RV_EXT_I)  <<  8) | // I - Integer extension
        (32'(RV_EXT_M)  << 12) | // M - Integer Multiply/Divide extension
        (0              << 13) | // N - User level interrupts supported
        (0              << 18) | // S - Supervisor mode implemented
        (32'(RV_EXT_U)  << 20) | // U - User mode implemented
        (0              << 23) | // X - Non-standard extensions present
        (32'(MISA_XLEN) << 30);  // M-XLEN 32bit


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

    Data mtime;        // Contador de temps
    Data mtimecmp;     // Comparador del contador de temps
    Data mcause;
    Data mscratch;

    logic       mstatus_SD;
    logic       mstatus_TSR;
    logic       mstatus_TW;
    logic       mstatus_TVM;
    logic       mstatus_MXR;
    logic       mstatus_SUM;
    logic       mstatus_MPRV;
    logic [1:0] mstatus_XS;
    logic [1:0] mstatus_FS;
    logic [1:0] mstatus_MPP;
    logic       mstatus_SPP;
    logic       mstatus_MPIE;
    logic       mstatus_SPIE;
    logic       mstatus_UPIE;
    logic       mstatus_MIE;
    logic       mstatus_SIE;
    logic       mstatus_UIE;

    logic [$size(InstAddr)-3:0] mtvec_BASE;
    logic [1:0]                 mtvec_MODE;

    logic       mie_MEIE;
    logic       mie_MTIE;
    logic       mie_MSIE;

    logic       mip_MEIP;
    logic       mip_MTIP;
    logic       mip_MSIP;

    logic       mcounteren_CY;
    logic       mcounteren_TM;
    logic       mcounteren_IR;

    logic       mcountinhibit_CY;
    logic       mcountinhibit_IR;

    Data mstatus;
    assign mstatus = {mstatus_SD, 8'b0, mstatus_TSR, mstatus_TW,
        mstatus_TVM, mstatus_MXR, mstatus_SUM, mstatus_MPRV, mstatus_XS,
        mstatus_FS, mstatus_MPP, 2'b0, mstatus_SPP, mstatus_MPIE, 1'b0,
        mstatus_SPIE, mstatus_UPIE, mstatus_MIE, 1'b0, mstatus_SIE,
        mstatus_UIE};

    Data mtvec;
    assign mtvec = {16'b0, mtvec_BASE, mtvec_MODE};

    Data mip;
    assign mip = {20'b0, mip_MEIP, 3'b0, mip_MTIP, 3'b0, mip_MSIP, 3'b0};

    Data mie;
    assign mie = {20'b0, mie_MEIE, 3'b0, mie_MTIE, 3'b0, mie_MSIE, 3'b0};

    Data mcounteren;
    assign mcounteren = {29'b0, mcounteren_IR, mcounteren_TM, mcounteren_CY};

    Data mcountinhibit;
    assign mcountinhibit = {29'b0, mcountinhibit_IR, 1'b1, mcountinhibit_CY};


    // -------------------------------------------------------------------
    // Actualitza o escriu en els contadors
    // -------------------------------------------------------------------

    always_ff @(posedge i_clock)
        unique casez ({i_reset, i_op})
           {1'b1, 2'b??}:
                begin
                    cycle   <= 0;
                    instret <= 0;
                end

            {1'b0, CsrOp_WRITE}:
                unique case (i_csr)
                    CSR_MCYCLE  : cycle   <= i_data;
                    CSR_MINSTRET: instret <= i_data;
                    default     : ;
                endcase

            default:
                begin
                    if (~mcountinhibit_CY)
                        cycle <= cycle + 1;
                    if (~mcountinhibit_IR & i_instRet)
                        instret <= instret + 1;
                end
        endcase


    // -------------------------------------------------------------------
    // Escriu en els registres d'estat i control
    // -------------------------------------------------------------------

    always_ff @(posedge i_clock)
        unique casez ({i_reset, i_op})
            {1'b1, 2'b??}:
                begin
                    mcounteren_CY    <= 1'b0;
                    mcounteren_TM    <= 1'b0;
                    mcounteren_IR    <= 1'b0;
                    mcountinhibit_CY <= 1'b1;
                    mcountinhibit_IR <= 1'b1;
                    mtvec_MODE       <= 2'b00;
                    mtvec_BASE       <= 0;
                    mie_MEIE         <= 1'b0;
                    mie_MSIE         <= 1'b0;
                    mie_MTIE         <= 1'b0;
                    mip_MEIP         <= 1'b0;
                    mip_MSIP         <= 1'b0;
                    mip_MTIP         <= 1'b0;
                    mstatus_SD       <= 1'b0;
                    mstatus_FS       <= 2'b00;
                end

            {1'b0, CsrOp_WRITE}:
                unique case (i_csr)
                    CSR_MSTATUS:
                        begin
                            mtvec_MODE <= i_data[1:0];
                            mtvec_BASE <= i_data[15:2];
                            mstatus_FS <= i_data[14:13];
                        end

                    CSR_MCOUNTEREN:
                        begin
                            mcounteren_CY <= i_data[0];
                            mcounteren_TM <= i_data[1];
                            mcounteren_IR <= i_data[2];
                        end

                    CSR_MCOUNTINHIBIT:
                        begin
                            mcountinhibit_CY <= i_data[0];
                            mcountinhibit_IR <= i_data[2];
                        end
                    default: ;
                endcase

            {1'b0, CsrOp_SET}:
                unique case (i_csr)
                    CSR_MCOUNTEREN:
                        begin
                            mcounteren_CY <= i_data[0] ? 1'b1 : mcounteren_CY;
                            mcounteren_TM <= i_data[1] ? 1'b1 : mcounteren_TM;
                            mcounteren_IR <= i_data[2] ? 1'b1 : mcounteren_IR;
                        end

                    CSR_MCOUNTINHIBIT:
                        begin
                            mcountinhibit_CY <= i_data[0] ? 1'b1 : mcountinhibit_CY;
                            mcountinhibit_IR <= i_data[2] ? 1'b1 : mcountinhibit_IR;
                        end
                    default: ;
                endcase

            {1'b0, CsrOp_CLEAR}:
                unique case (i_csr)
                    CSR_MCOUNTEREN:
                        begin
                            mcounteren_CY <= i_data[0] ? 1'b0 : mcounteren_CY;
                            mcounteren_TM <= i_data[1] ? 1'b0 : mcounteren_TM;
                            mcounteren_IR <= i_data[2] ? 1'b0 : mcounteren_IR;
                        end

                    CSR_MCOUNTINHIBIT:
                        begin
                            mcountinhibit_CY <= i_data[0] ? 1'b0 : mcountinhibit_CY;
                            mcountinhibit_IR <= i_data[2] ? 1'b0 : mcountinhibit_IR;
                        end
                    default: ;
                endcase

            default:
                ;
        endcase


    // -------------------------------------------------------------------
    // Llegeix els registres
    // -------------------------------------------------------------------

    always_comb begin
        case (i_csr)
            CSR_MCAUSE        : o_data = mcause;
            CSR_MCYCLE        : o_data = cycle;
            CSR_MCOUNTEREN    : o_data = mcounteren;
            CSR_MCOUNTINHIBIT : o_data = mcountinhibit;
            CSR_MIE           : o_data = mie;
            CSR_MIP           : o_data = mip;
            CSR_MINSTRET      : o_data = instret;
            CSR_MISA          : o_data = MISA;
            CSR_MSCRATCH      : o_data = mscratch;
            CSR_MSTATUS       : o_data = mstatus;
            CSR_MTVEC         : o_data = mtvec;
            default           : o_data = Data'(0);
        endcase
    end


endmodule
