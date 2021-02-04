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
    import Types::*;
#(
    parameter BASE = 0,
    parameter SIZE = 1024)
(
    input  logic  i_clock,
    DataBus.slave bus);

    localparam DATA_WIDTH = $size(Data);

    longint memObj;

    // Emula per DPI una memoria de 32 bits, direccionable en bytes
    //
    import "DPI-C" function int dpiMemCreate(input int base, input int size, output longint memObj);
    import "DPI-C" function int dpiMemDestroy(input longint memObj);
    import "DPI-C" function void dpiMemWrite(input longint memObj, input int addr, input int access, input int data);
    import "DPI-C" function int dpiMemRead(input longint memObj, input int addr, input int access);


    always_ff @(posedge i_clock)
        if (bus.we)
            dpiMemWrite(memObj, bus.addr, int'(bus.access), bus.wdata);

    assign bus.rdata = dpiMemRead(memObj, bus.addr, int'(bus.access));


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