module DebugController
    import Types::*;
(
    // Senyals de control
    input  logic    i_clock,       // Clock
    input  logic    i_reset,       // Reset

    // Senyals per la generacio del tick
    input  logic    i_stall,       // Indica stall
    output int      o_tick,        // Numero de tick

    // Senyals d'estat de la ultima instruccio executada
    input  int      i_tick,        // Numero de tick
    input  logic    i_ok,          // Instruccio
    input  InstAddr i_pc,          // Adressa de la instruccio
    input  Inst     i_inst,        // Instruccio
    input  RegAddr  i_regWrAddr,   // Registre per escriure
    input  logic    i_regWrEnable, // Autoritzacio d'escritura en el registre
    input  Data     i_regWrData,   // Dades per escriure en el registre
    input  DataAddr i_memWrAddr,   // Adressa de memoria per escriure
    input  logic    i_memWrEnable, // Autoritzacio d'escriptura en memoria
    input  Data     i_memWrData);  // Dades per escriure en memoria

    always_ff @(posedge i_clock)
        o_tick <= i_reset ? 0 : (i_stall ? o_tick : o_tick + 1);


`ifdef VERILATOR

    import "DPI-C" function void TraceInstruction(input int addr, input int data);
    import "DPI-C" function void TraceRegister(input int addr, input int data);
    import "DPI-C" function void TraceMemory(input int addr, input int data);
    import "DPI-C" function void TraceTick(input int tick);

    always_ff @(posedge i_clock)
        if (!i_reset & i_ok) begin

            TraceTick(i_tick);

            TraceInstruction(i_pc, i_inst);

            if ((i_regWrAddr != 0) & i_regWrEnable)
                TraceRegister(i_regWrAddr, i_regWrData);

            if (i_memWrEnable)
                TraceMemory(i_memWrAddr, i_memWrData);

            $display("");
        end

`endif


endmodule
