// -----------------------------------------------------------------------
//
//       Memoria de dades 32 bits, direccionable en bytes.
//       La memoria es emulada en una llibreria DPI per la
//       seva utilitzacio en Verilator
//
//       Parametres:
//            BASE      : Adresa de memoria base
//            SIZE      : Tamany de la memoria en bytes
//
//       Entrades:
//            i_clock   : Senyal de rellotge
//
//       Bus:
//            bus       : Bus de memoria de dades
//
// -----------------------------------------------------------------------

module DataMemory
    import CoreDefs::*;
#(
    parameter BASE = 0,
    parameter SIZE = 1024)
(
    input  logic  i_clock,
    DataBus.slave bus);

    localparam DATA_WIDTH = $size(Data);

    longint memObj;

    // Emula per DPI una memoria de 32 bits, direccionable en words. L'escriptura dels
    // bytes individuals es realitza per mascara (be)
    //
    import "DPI-C" function int dpiMemCreate(input int base, input int size, output longint memObj);
    import "DPI-C" function int dpiMemDestroy(input longint memObj);
    import "DPI-C" function void dpiMemWrite8(input longint memObj, input int addr, input int data);
    import "DPI-C" function int dpiMemRead32(input longint memObj, input int addr);


    always_ff @(posedge i_clock)
        if (bus.we) begin
            if (bus.be[0])
                dpiMemWrite8(memObj, int'(bus.addr), int'(bus.wdata[7:0]));
            if (bus.be[1])
                dpiMemWrite8(memObj, int'(bus.addr + 1), int'(bus.wdata[15:8]));
            if (bus.be[2])
                dpiMemWrite8(memObj, int'(bus.addr + 2), int'(bus.wdata[23:16]));
            if (bus.be[3])
                dpiMemWrite8(memObj, int'(bus.addr + 3), int'(bus.wdata[31:24]));
        end

    assign bus.rdata = dpiMemRead32(memObj, int'(bus.addr));
    assign bus.busy = 1'b0;


    initial begin
        if (dpiMemCreate(BASE, SIZE, memObj) != 0) begin
            $display("Create memory error.");
            $finish();
        end

        $display("Emulated RAM memory %0d bits:", DATA_WIDTH);
        $display("    Base addr     : %X", BASE);
        $display("    Size in bytes : %0d", SIZE);
        $display("");
    end

    final
        // verilator lint_off IGNOREDRETURN
        dpiMemDestroy(memObj);
        // verilator lint_on IGNOREDRETURN

    function longint getMemObj; // verilator public
	    return memObj;
    endfunction

endmodule