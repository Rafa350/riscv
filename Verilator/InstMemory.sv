// -----------------------------------------------------------------------
//
//       Memoria d'instruccions 32 bits, direccionable en bytes.
//       La memoria es emulada en una llibreria DPI per la
//       seva utilitzacio en Verilator
//
//       Parametres:
//            BASE      : Adresa de memoria base
//            SIZE      : Tamany de la memoria en bytes
//            FILE_NAME : El fitxer de dades per carregar
//
//       Bus:
//            bus       : Bus de memoria d'instruccions
//
// -----------------------------------------------------------------------

module InstMemory
    import Types::*;
#(
    parameter BASE      = 0,
    parameter SIZE      = 1024,
    parameter FILE_NAME = "data.txt")
(
    InstMemoryBus.slave bus);

    localparam DATA_WIDTH = $size(Data);

    longint memObj;

    // Emula per DPI una memoria de 32 bits, direccionable en bytes
    //
    import "DPI-C" function int dpiMemCreate(input int base, input int size, output longint memObj);
    import "DPI-C" function int dpiMemDestroy(input longint memObj);
    import "DPI-C" function int dpiMemLoad(input longint memObj, input string fileName);
    import "DPI-C" function int dpiMemRead(input longint memObj, input int addr, input int access);


    assign bus.inst = dpiMemRead(memObj, int'(bus.addr), int'(2'b10));


    initial begin
        if (dpiMemCreate(BASE, SIZE, memObj) != 0) begin
            $display("Create memory error.");
            $finish();
        end

        if (dpiMemLoad(memObj, FILE_NAME) != 0) begin
            $display("Load file error.");
            $finish();
        end

        $display("Emulated ROM memory %0d bits:", DATA_WIDTH);
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