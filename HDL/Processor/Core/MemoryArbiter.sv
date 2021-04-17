module MemoryArbiter
    import CoreDefs::*;
(
    input               logic  i_clock,
    input               logic  i_reset,

    InstBus.slave       instBus,
    DataBus.slave       dataBus,

    output logic [31:0] o_mem_addr,
    output logic        o_mem_we,
    output logic        o_mem_re,
    input  logic [31:0] i_mem_rdata,
    output logic [31:0] o_mem_wdata);

    always_comb begin
        if (instBus.re) begin
            dataBus.busy = dataBus.re | dataBus.we;
            o_mem_addr   = instBus.addr;
            o_mem_re     = 1'b1;
            o_mem_we     = 1'b0;
            instBus.inst = i_mem_rdata;
            instBus.busy = 1'b0;
        end
        else if (dataBus.re) begin
            instBus.busy  = instBus.re;
            o_mem_addr    = dataBus.addr;
            o_mem_re      = 1'b1;
            o_mem_we      = 1'b0;
            dataBus.rdata = i_mem_rdata;
            dataBus.busy  = 1'b0;
        end
        else if (dataBus.we) begin
            instBus.busy  = instBus.re;
            o_mem_addr    = dataBus.addr;
            o_mem_re      = 1'b0;
            o_mem_we      = 1'b1;
            o_mem_wdata   = dataBus.wdata;
            dataBus.busy  = 1'b0;
        end
        else begin
            instBus.busy  = 1'b0;
            instBus.inst  = Inst'(0);
            dataBus.busy  = 1'b0;
            dataBus.rdata = Data'(0);
        end
    end

endmodule
