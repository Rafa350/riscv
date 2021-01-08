// -----------------------------------------------------------------------
// Implementa un bloc de registres tipus MIPS
// -Un port d'entrada per escriptura del registre 1..N
// -Dos ports independents de lectura dels registres 0 a N
// -El registre 0 sempre val zero
// -Durant el reset, tots els registres s'asignen al valor zero.
//
module RegisterFile
    import Types::*;
(
    // Control
    input  logic   i_clock,  // Clock
    input  logic   i_reset,  // Reset

    // Interficie
    RegisterBus    bus);     // Interficie

    localparam SIZE = 2**$size(RegAddr);
    localparam ZERO = {$size(Data){1'b0}};


    Data data[1:SIZE-1];


    // Proces d'escriptura sincrona
    //
    always_ff @(posedge i_clock)
        if (i_reset) begin
            for (int i = $left(data); i <= $right(data); i++)
                data[i] <= ZERO;
        end
        else if (bus.slaveWriter.wrEnable & (bus.slaveWriter.wrAddr != 0))
            data[bus.slaveWriter.wrAddr] <= bus.slaveWriter.wrData;

    // Proces de lectura asincrona
    //
    always_comb begin
        bus.slaveReader.rdDataA = (i_reset | (bus.slaveReader.rdAddrA == 0)) ? ZERO : data[bus.slaveReader.rdAddrA];
        bus.slaveReader.rdDataB = (i_reset | (bus.slaveReader.rdAddrB == 0)) ? ZERO : data[bus.slaveReader.rdAddrB];
    end


endmodule
