module DebugController
    import Types::*;
(
    // Senyals de control
    input  logic       i_clock,       // Clock
    input  logic       i_reset,       // Reset

    // Senyals per la generacio del tick
    input  logic       i_stall,       // Indica stall
    output int         o_tick,        // Numero de tick

    // Senyals d'estat de la ultima instruccio executada
    input  int         i_tick,        // Numero de tick
    input  logic       i_ok,          // Instruccio
    input  InstAddr    i_pc,          // Adressa de la instruccio
    input  Inst        i_inst,        // Instruccio
    input  RegAddr     i_regWrAddr,   // Registre per escriure
    input  logic       i_regWrEnable, // Autoritzacio d'escritura en el registre
    input  Data        i_regWrData,   // Dades per escriure en el registre
    input  DataAddr    i_memWrAddr,   // Adressa de memoria per escriure
    input  logic       i_memWrEnable, // Autoritzacio d'escriptura en memoria
    input  Data        i_memWrData);  // Dades per escriure en memoria

    always_ff @(posedge i_clock)
        o_tick <= i_reset ? 0 : (i_stall ? o_tick : o_tick + 1);


`ifdef VERILATOR

    longint tracerObj;

    import "DPI-C" function int dpiTracerCreate(output longint tracerObj);
    import "DPI-C" function int dpiTracerDestroy(input longint tracerObj);
    import "DPI-C" function void dpiTraceInstruction(input longint tracerObj, input int addr, input int data);
    import "DPI-C" function void dpiTraceRegister(input longint tracerObj, input int addr, input int data);
    import "DPI-C" function void dpiTraceMemory(input longint tracerObj, input int addr, input int data);
    import "DPI-C" function void dpiTraceTick(input longint tracerObj, input int tick);

    always_ff @(posedge i_clock)
        if (!i_reset & i_ok) begin

            dpiTraceTick(tracerObj, i_tick);

            dpiTraceInstruction(tracerObj, int'(i_pc), i_inst);

            if ((i_regWrAddr != 0) & i_regWrEnable)
                dpiTraceRegister(tracerObj, int'(i_regWrAddr), i_regWrData);

            if (i_memWrEnable)
                dpiTraceMemory(tracerObj, int'(i_memWrAddr), i_memWrData);

            $display("");
        end

    initial
        if (dpiTracerCreate(tracerObj) != 0) begin
            $display("Create tracer error.");
            $finish();
        end

    final
        // verilator lint_off IGNOREDRETURN
        dpiTracerDestroy(tracerObj);
        // verilator lint_on IGNOREDRETURN

`endif


endmodule
