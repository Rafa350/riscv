module CSRBlock
    import Types::*;
(
    // Senyals de control
    input  logic        i_clock,
    input  logic        i_reset,

    // Senyals d'acces per ISA
    input  CRRegAddr    i_addr,
    input  logic        i_wrEnable,
    input  Data         i_wrData,
    output Data         o_rdData

    // Senyals d'acces directe
    input logic  [31:0] i_time,
    input logic  [31:0] i_instRet);


    localparam Data MISA =
        (1'b0   <<  0) |     // A - Atomic Instructions extension
`ifdef RV_EXT_C
        (1'b1   <<  2) |     // C - Compressed extension
`endif
        (1'b0   <<  3) |     // D - Double precision floating-point extension
`ifdef RV_EXT_E
        (1'b1   <<  4) |     // E - RV32E base ISA
`endif
        (1'b0   <<  5) |     // F - Single precision floating-point extension
        (1'b1   <<  8) |     // I - RV32I/64I/128I base ISA
`ifdef RV_EXT_M
        (1'b1   << 12) |     // M - Integer Multiply/Divide extension
`endif
        (1'b0   << 13) |     // N - User level interrupts supported
        (1'b0   << 18) |     // S - Supervisor mode implemented
        (1'b1   << 20) |     // U - User mode implemented
        (1'b0   << 23) |     // X - Non-standard extensions present
        (2'b01  << 30);      // M-XLEN


    localparam CSR_USTATUS  = 12'h000;
    localparam CSR_UIE      = 12'h004;
    localparam CSR_UTVEC    = 12'h005;

    localparam CSR_USCRATCH = 12'h040;
    localparam CSR_UEPC     = 12'h041;
    localparam CSR_UCAUSE   = 12'h042;
    localparam CSR_UTVAL    = 12'h043;
    localparam CSR_UIP      = 12'h044;

    localparam CSR_FFLAGS   = 12'h001;
    localparam CSR_FRM      = 12'h002;
    localparam CSR_FCSR     = 12'h003;

    localparam CSR_CYCLE    = 12'hC00;
    localparam CSR_TIME     = 12'hC01;
    localparam CSR_INSTRET  = 12'hC02;

    localparam CSR_MSTATUS  = 12'h300;
    localparam CSR_MISA     = 12'h301;
    localparam CSR_MIE      = 12'h304;
    localparam CSR_MSCRATCH = 12'h340;
    localparam CSR_MEPC     = 12'h341;
    localparam CSR_MCAUSE   = 12'h342;
    localparam CSR_MIP      = 12'h344;

    localparam CSR_CYCLEH   = 12'hC80;
    localparam CSR_TIMEH    = 12'hC81;
    localparam CSR_INSTRETH = 12'hC82;


    // -------------------------------------------------------------------
    // Contador de cicles
    // -------------------------------------------------------------------

    logic [31:0] cicle;

    always_ff @(posedge i_clock) begin
        if (i_reset)
            cicle <= 0;
        else
            cicle <= cicle + 1;
    end


    // -------------------------------------------------------------------
    // Access RW als registres
    // -------------------------------------------------------------------

    // CSR MSTATUS
    Data mstatus;
    assign mstatus = 0;


    always_ff @(posedge i_clock) begin
        if (i_reset) begin
        end
        else if (i_wrEnable) begin
            case (i_addr)
            endcase
        end
    end

    always_comb begin
        case (i_addr)
            CSR_CYCLE   : o_rdData = cicle;
            CSR_INSTRET : o_rdData = i_instRet;
            CSR_MISA    : o_rdData = MISA;
            CAR_MSTATUS : o_rdData = mstatus;
            CSR_TIME    : o_rdData = i_time;
        endcase
    end


endmodule
