module MemoryArbiter (                                        
                                       // Senyals de sincronitzacio i control
    input  logic        i_clock,       // Clock 
    input  logic        i_reset,       // Reset
                                       // Busos
    InstBus.slave       instBus,       // Bus d'instruccions
    DataBus.slave       dataBus,       // Bus de dades
                                       // Control d'access a la memoria
    output logic [31:0] o_mem_addr,    // Adressa de memoriaº
    output logic        o_mem_we,      // Write enable
    output logic        o_mem_re,      // RTead enable
    input  logic [31:0] i_mem_rdata,   // Dades per lleigir
    output logic [31:0] o_mem_wdata);  // Dades per escriure

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
            instBus.inst  = ProcessorDefs::Inst'(0);
            dataBus.busy  = 1'b0;
            dataBus.rdata = ProcessorDefs::Data'(0);
        end
    end

endmodule
