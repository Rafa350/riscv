module DataMemory
    import Types::*;
#(
    parameter BASE = 0,
    parameter SIZE = 1024)
(
    input  logic        i_clock,
    DataMemoryBus.slave bus);

    localparam DATA_WIDTH = $size(Data);

    longint memObj;

    import "DPI-C" function int dpiMemCreate(input int base, input int size, output longint memObj);
    import "DPI-C" function int dpiMemDestroy(input longint memObj);
    import "DPI-C" function void dpiMemWrite(input longint memObj, input int addr, input int mask, input int data);
    import "DPI-C" function int dpiMemRead(input longint memObj, input int addr);

    always_ff @(posedge i_clock)
        if (bus.wrEnable)
            dpiMemWrite(memObj, bus.addr, int'(bus.wrMask), bus.wrData);

    assign bus.rdData = dpiMemRead(memObj, bus.addr);


    initial begin
        if (dpiMemCreate(BASE, SIZE, memObj) == 0) begin
            $display("Emulated RAM memory %0dbit:", DATA_WIDTH);
            $display("    Base addr     : %X", BASE);
            $display("    Size in bytes : %0d", SIZE);
            $display("");
        end
        else begin
            $display("Error al crear la memoria.");
            $finish();
        end
    end

    final
        // verilator lint_off IGNOREDRETURN
        dpiMemDestroy(memObj);
        // verilator lint_on IGNOREDRETURN

    function longint getMemObj; // verilator public
	    return memObj;
    endfunction

endmodule